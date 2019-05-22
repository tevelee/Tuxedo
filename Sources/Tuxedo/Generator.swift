//
//  Generate.swift
//  Eval
//
//  Created by László Teveli on 2019. 05. 21..
//

import Foundation

public class Generator {
    let tuxedo: Tuxedo
    let fileManager: FileManager
    let fileExtension: String
    let rootPath: String
    
    public init(tuxedo: Tuxedo = Tuxedo(),
                fileManager: FileManager = .default,
                fileExtension: String = "template",
                rootPath: String = CommandLine.arguments[0]) {
        self.tuxedo = tuxedo
        self.fileManager = fileManager
        self.fileExtension = fileExtension
        self.rootPath = Generator.resolvePath(script: rootPath)
    }
    
    public func generate() -> [String] {
        return Generator.files(with: fileExtension, in: rootPath, using: fileManager)
            .compactMap { path in
                if let content = generate(fromTemplate: path) {
                    let filePath = (path as NSString).deletingPathExtension
                    write(content: content, at: filePath)
                    return filePath
                }
                return nil
            }
    }
    
    func generate(fromTemplate atPath: String) -> String? {
        let url = URL(fileURLWithPath: atPath)
        return try? tuxedo.evaluate(template: url)
    }
    
    func write(content: String, at path: String) -> Void {
        if let data = content.data(using: .utf8) {
            try? data.write(to: URL(fileURLWithPath: path))
        }
        return Void()
    }
    
    static func files(with fileExtension: String,
                             in path: String,
                             using fileManager: FileManager) -> [String] {
        guard let files = try? fileManager.contentsOfDirectory(atPath: path) else { return [] }
        return files
            .flatMap { file -> [String] in
                let filePath = "\(path)/\(file)"
                var isDirectory: ObjCBool = false
                fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory)
                if isDirectory.boolValue {
                    return self.files(with: fileExtension, in: filePath, using: fileManager)
                } else {
                    return [filePath]
                }
            }
            .filter { $0.hasSuffix(".\(fileExtension)") }
    }
    
    static func resolvePath(script: String) -> String {
        let isAbsolutePath = script.hasPrefix("/")
        if isAbsolutePath {
            return script.deletingLastPathComponent()
        } else {
            let cwd = FileManager.default.currentDirectoryPath
            let cwdUrl = URL(fileURLWithPath: cwd)
            if let url = URL(string: script, relativeTo: cwdUrl) {
                return url.path.deletingLastPathComponent()
            }
            return cwd
        }
    }
}

fileprivate extension String {
    func deletingLastPathComponent() -> String {
        return (self as NSString).deletingLastPathComponent
    }
}
