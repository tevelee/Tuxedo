@_exported import Eval
@_exported import class Eval.Pattern
import Foundation

public class Tuxedo {
    public typealias EvaluatedType = String

    let language: StringTemplateInterpreter
    let macroReplacer: StringTemplateInterpreter

    public init(dataTypes: [DataTypeProtocol] = StandardLibrary.dataTypes,
                functions: [FunctionProtocol] = StandardLibrary.functions,
                tags: [Pattern<String, TemplateInterpreter<String>>] = StandardLibrary.tags,
                globalVariables: [String: Any] = [:]) {
        let context = Context(variables: globalVariables)
        Tuxedo.preprocess(context)

        let interpreter = TypedInterpreter(dataTypes: dataTypes, functions: functions, context: context)
        let language = StringTemplateInterpreter(statements: tags, interpreter: interpreter, context: context)
        self.language = language

        let block = Pattern<String, TemplateInterpreter<String>>([OpenKeyword("{{{"), TemplateVariable("name", options: .notInterpreted), CloseKeyword("}}}")]) {
            guard let name = $0.variables["name"] as? String else { return nil }
            return language.context.blocks[name]?.last?(language.context)
        }
        macroReplacer = StringTemplateInterpreter(statements: [block])
    }

    public func evaluate(_ expression: String, variables: [String: Any] = [:]) -> String {
        let context = Context(variables: variables)
        Tuxedo.preprocess(context)
        let input = replaceWhitespaces(expression)
        let result = language.evaluate(input, context: context)
        let finalResult = macroReplacer.evaluate(result)
        return finalResult.contains(StandardLibrary.tagPrefix) ? language.evaluate(finalResult, context: context) : finalResult
    }

    public func evaluate(template from: URL, variables: [String: Any] = [:]) throws -> String {
        let expression = try String(contentsOf: from)
        return evaluate(expression, variables: variables)
    }

    static func preprocess(_ context: Context) {
        context.variables = context.variables.mapValues { value in
            convert(value) {
                if let integerValue = $0 as? Int {
                    return Double(integerValue)
                }
                return $0
            }
        }
    }

    static func convert(_ value: Any, recursively: Bool = true, convert: @escaping (Any) -> Any) -> Any {
        if recursively, let array = value as? [Any] {
            return array.map { convert($0) }
        }
        if recursively, let dictionary = value as? [String: Any] {
            return dictionary.mapValues { convert($0) }
        }
        return convert(value)
    }

    func replaceWhitespaces(_ input: String) -> String {
        let tag = "{-}"
        var input = input
        repeat {
            if var range = input.range(of: tag) {
                searchForward: while true {
                    if range.upperBound < input.index(before: input.endIndex) {
                        let nextIndex = range.upperBound
                        if let unicodeScalar = input[nextIndex].unicodeScalars.first,
                            CharacterSet.whitespacesAndNewlines.contains(unicodeScalar) {
                            range = Range(uncheckedBounds: (lower: range.lowerBound, upper: input.index(after: range.upperBound)))
                        } else {
                            break searchForward
                        }
                    } else {
                        break searchForward
                    }
                }
                searchBackward: while true {
                    if range.lowerBound > input.startIndex {
                        let nextIndex = input.index(before: range.lowerBound)
                        if let unicodeScalar = input[nextIndex].unicodeScalars.first,
                            CharacterSet.whitespacesAndNewlines.contains(unicodeScalar) {
                            range = Range(uncheckedBounds: (lower: input.index(before: range.lowerBound), upper: range.upperBound))
                        } else {
                            break searchBackward
                        }
                    } else {
                        break searchBackward
                    }
                }
                input.replaceSubrange(range, with: "")
            }
        } while input.contains(tag)
        return input
    }
}
