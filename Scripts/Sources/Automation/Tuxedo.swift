import Foundation
import PathKit
import xcproj

class Tuxedo {
    static func main() {
        print("💁🏻‍♂️ Job type: \(TravisCI.jobType().description)")

        if isSpecificJob() {
            return
        }

        if TravisCI.isPullRquestJob() || Shell.nextArg("--env") == "pr" {
            runPullRequestLane()
        } else {
            runContinousIntegrationLane()
        }
    }

    static func runPullRequestLane() {
        runCommands("Building Pull Request") {
            try prepareForBuild()
            try build()
            try runTests()

            try runLinter()
            try runDanger()
        }
    }

    static func runContinousIntegrationLane() {
        runCommands("Building CI") {
            try prepareForBuild()
            try build()
            try runTests()

            try generateDocs()
            try publishDocs()

            try runLinter()
            try runCocoaPodsLinter()

            try testCoverage()

            try runDanger()

            try releaseNewVersion()
        }
    }

    static func isSpecificJob() -> Bool {
        guard let jobsString = Shell.nextArg("--jobs") else { return false }
        let jobsToRun = jobsString.split(separator: ",").map { String($0) }
        let jobsFound = jobsToRun.flatMap { job in jobs.first { $0.key == job } }
        runCommands("Executing jobs: \(jobsString)") {
            if let job = jobsToRun.first(where: { !self.jobs.keys.contains($0) }) {
                throw CIError.logicalError(message: "Job not found: \(job)")
            }
            try jobsFound.forEach {
                print("🏃🏻 Running job \($0.key)")
                try $0.value()
            }
        }
        return !jobsFound.isEmpty
    }

    static func runCommands(_ title: String, commands: () throws -> Void) {
        do {
            if !TravisCI.isRunningLocally() {
                print("travis_fold:start: \(title)")
            }

            print("ℹ️ \(title)")
            try commands()

            if !TravisCI.isRunningLocally() {
                print("travis_fold:end: \(title)")
            }

            print("🎉 Finished successfully")
        } catch let CIError.invalidExitCode(statusCode, errorOutput) {
            print("😢 Error happened: [InsufficientExitCode] ", errorOutput ?? "unknown error")
            exit(statusCode)
        } catch let CIError.logicalError(message) {
            print("😢 Error happened: [LogicalError] ", message)
            exit(-1)
        } catch CIError.timeout {
            print("🕙 Timeout")
            exit(-1)
        } catch {
            print("😢 Error happened [General]")
            exit(-1)
        }
    }

    // MARK: Tasks

    static let jobs: [String: () throws -> Void] = [
        "prepareForBuild": prepareForBuild,
        "build": build,
        "runTests": runTests,
        "runLinter": runLinter,
        "generateDocs": generateDocs,
        "publishDocs": publishDocs,
        "runCocoaPodsLinter": runCocoaPodsLinter,
        "testCoverage": testCoverage,
        "runDanger": runDanger
    ]

    static func prepareForBuild() throws {
        if TravisCI.isRunningLocally() {
            print("🔦 Install dependencies")
            try Shell.executeAndPrint("rm -f Package.resolved")
            try Shell.executeAndPrint("rm -rf .build")
            try Shell.executeAndPrint("rm -rf build")
            try Shell.executeAndPrint("rm -rf Tuxedo.xcodeproj")
            try Shell.executeAndPrint("bundle install")
        }

        print("🤖 Generating project file")
        try Shell.executeAndPrint("swift package generate-xcodeproj --enable-code-coverage", timeout: 120)
        print("📦 Adding resources to project file")
        try performManualSteps()
    }

    static func build() throws {
        print("♻️ Building")
        try Shell.executeAndPrint("swift build", timeout: 120)
        try Shell.executeAndPrint("xcodebuild clean build -configuration Release -scheme Tuxedo-Package | bundle exec xcpretty --color", timeout: 120)
    }

    static func runTests() throws {
        print("👀 Running automated tests")
        try Shell.executeAndPrint("xcodebuild test -configuration Release -scheme Tuxedo-Package -enableCodeCoverage YES | bundle exec xcpretty --color", timeout: 120)
    }

    static func runLinter() throws {
        print("👀 Running linter")
        try Shell.executeAndPrint("swiftlint lint", timeout: 60)
    }

    static func generateDocs() throws {
        print("📚 Generating documentation")
        try Shell.executeAndPrint("pushd website && npm build && popd", timeout: 120)
    }

    static func publishDocs() throws {
        print("📦 Publishing documentation")

        defer {
            print("📦 ✨ Cleaning up")
            try! Shell.executeAndPrint("rm -rf website/build")
        }

        if TravisCI.isRunningLocally() {
            print("📦 ✨ Preparing")
            try Shell.executeAndPrint("rm -rf website/build")
        }

        try Shell.executeAndPrint("pushd website && npm run publish-gh-pages && popd", timeout: 60)
    }

    static func runCocoaPodsLinter() throws {
        print("🔮 Validating CocoaPods support")
        let flags = TravisCI.isRunningLocally() ? "--verbose" : ""
        try Shell.executeAndPrint("bundle exec pod lib lint \(flags)", timeout: 300)
    }

    static func testCoverage() throws {
        defer {
            print("📦 ✨ Cleaning up")
            try! Shell.executeAndPrint("rm -f Tuxedo.framework.coverage.txt")
            try! Shell.executeAndPrint("rm -f TuxedoTests.xctest.coverage.txt")
        }

        print("☝🏻 Uploading code test coverage data")
        try Shell.executeAndPrint("bash <(curl -s https://codecov.io/bash) -J Tuxedo", timeout: 120)
    }

    static func runDanger() throws {
        if TravisCI.isRunningLocally() {
            print("⚠️ Running Danger in local mode")
            try Shell.executeAndPrint("bundle exec danger pr --verbose || true", timeout: 120)
        } else if TravisCI.isPullRquestJob() {
            print("⚠️ Running Danger")
            try Shell.executeAndPrint("bundle exec danger --verbose || true", timeout: 120)
        }
    }

    static func releaseNewVersion() throws {
        guard case .travisPushOnBranch(_) = TravisCI.jobType() else { return }

        if let message = try commitMessage() {
            let message = message.trimmingCharacters(in: .whitespacesAndNewlines)
            let regex = try NSRegularExpression(pattern: "^Version (\\d{1,2}\\.\\d{1,2}\\.\\d{1,2})$")
            let matches = regex.numberOfMatches(in: message, range: NSRange(message.startIndex..., in: message))
            if matches > 0, let currentTag = try Shell.execute("git show HEAD~1:.version")?.output {
                let currentTag = currentTag.trimmingCharacters(in: .whitespacesAndNewlines)
                let tag = message.replacingOccurrences(of: "Version ", with: "")

                guard let tags = try Shell.execute("git tag -l")?.output?.components(separatedBy: .whitespacesAndNewlines),
                    !tags.contains(tag) else { return }

                print("🤖 Applying new version \(tag) in project")
                let files = ["README.md", ".version", "Tuxedo.podspec"]
                for file in files {
                    try Shell.executeAndPrint("sed -i '' 's/\(currentTag)/\(tag)/g' \(file)")
                    try Shell.executeAndPrint("git add \(file)")
                }
                try Shell.executeAndPrint("git commit --amend --no-edit")

                print("🔖 Tagging \(tag)")
                try Shell.executeAndPrint("git tag \(tag) HEAD")

                print("💁🏻 Pushing changes")
                try Shell.executeAndPrint("git remote add ssh_origin git@github.com:tevelee/Tuxedo.git")
                try Shell.executeAndPrint("git push ssh_origin HEAD:master --force")
                try Shell.executeAndPrint("git push ssh_origin HEAD:master --force --tags")

                print("📦 Releasing package managers")
                try Shell.executeAndPrint("pod trunk push . || true", timeout: 600)
            }
        }
    }

    // MARK: Helpers

    static func currentRepositoryUrl(dir: String = ".") -> String? {
        if let command = try? Shell.execute("git -C \(dir) config --get remote.origin.url"),
            let output = command?.output?.trimmingCharacters(in: .whitespacesAndNewlines), !output.isEmpty {
            return output
        }
        return nil
    }

    static func currentBranch(dir: String = ".") -> String? {
        if let command = try? Shell.execute("git -C \(dir) rev-parse --abbrev-ref HEAD"),
            let output = command?.output?.trimmingCharacters(in: .whitespacesAndNewlines), !output.isEmpty {
            return output
        }
        return nil
    }

    static func commitMessage(dir: String = ".") throws -> String? {
        if TravisCI.isRunningLocally() {
            return try Shell.execute("git -C \(dir) log -1 --pretty=%B")?.output
        } else {
            return Shell.env(name: "TRAVIS_COMMIT_MESSAGE")
        }
    }

    // MARK: Manual steps

    static func performManualSteps() throws {
        let path = Path("Tuxedo.xcodeproj")
        let project = try XcodeProj(path: path)

        let testsGroup = project.pbxproj.objects.groups.first { $0.value.name == "TuxedoTests" }

        let phase = PBXResourcesBuildPhase()
        let ref = project.pbxproj.objects.generateReference(phase, "CopyResourcesBuildPhase")
        project.pbxproj.objects.addObject(phase, reference: ref)

        if let target = project.pbxproj.objects.targets(named: "TuxedoTests").first {
            target.object.buildPhases.append(ref)
        }

        let tests = Path("Tests/TuxedoTests")
        let files = try tests.children().flatMap { $0.components.last }.filter { $0.hasSuffix("txt") }
        for file in files {
            let fileRef = PBXFileReference(sourceTree: .group, name: nil, path: file)
            fileRef.fileEncoding = 4 //utf8
            let ref = project.pbxproj.objects.generateReference(fileRef, file)
            project.pbxproj.objects.fileReferences.append(fileRef, reference: ref)

            let buildFile = PBXBuildFile(fileRef: ref)
            let buildFileRef = project.pbxproj.objects.generateReference(buildFile, file)
            project.pbxproj.objects.buildFiles.append(buildFile, reference: buildFileRef)

            testsGroup?.value.children.append(ref)
            phase.files.append(buildFileRef)
        }

        try project.writePBXProj(path: path)
    }
}
