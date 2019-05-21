import Foundation

public class StandardLibrary {
    // MARK: Literal helpers

    public static func literal<T>(opening: String, closing: String, convert: @escaping (_ input: String, _ interpreter: TypedInterpreter) -> T?) -> Literal<T> {
        return Literal { literal -> T? in
            let input = literal.value
            guard input.hasPrefix(opening), input.hasSuffix(closing), input.count > 1 else { return nil }
            let inputWithoutOpening = String(input.suffix(from: input.index(input.startIndex, offsetBy: opening.count)))
            let inputWithoutSides = String(inputWithoutOpening.prefix(upTo: inputWithoutOpening.index(inputWithoutOpening.endIndex, offsetBy: -closing.count)))
            guard !inputWithoutSides.contains(opening) && !inputWithoutSides.contains(closing) else { return nil }
            return convert(inputWithoutSides, literal.interpreter)
        }
    }

    // MARK: Operator helpers

    public static func infixOperator<A, B, T>(_ symbol: String, body: @escaping (A, B) -> T) -> Function<T> {
        return Function([Variable<A>("lhs"), Keyword(symbol), Variable<B>("rhs")], options: .backwardMatch) {
            guard let lhs = $0.variables["lhs"] as? A, let rhs = $0.variables["rhs"] as? B else { return nil }
            return body(lhs, rhs)
        }
    }

    public static func prefixOperator<A, T>(_ symbol: String, body: @escaping (A) -> T) -> Function<T> {
        return Function([Keyword(symbol), Variable<A>("value")]) {
            guard let value = $0.variables["value"] as? A else { return nil }
            return body(value)
        }
    }

    public static func suffixOperator<A, T>(_ symbol: String, body: @escaping (A) -> T) -> Function<T> {
        return Function([Variable<A>("value"), Keyword(symbol)]) {
            guard let value = $0.variables["value"] as? A else { return nil }
            return body(value)
        }
    }

    // MARK: Function helpers

    public static func function<T>(_ name: String, body: @escaping ([Any]) -> T?) -> Function<T> {
        return Function([Keyword(name), OpenKeyword("("), Variable<String>("arguments", options: .notInterpreted), CloseKeyword(")")]) { fun in
            guard let arguments = fun.variables["arguments"] as? String else { return nil }
            let interpretedArguments = arguments.split(separator: ",").compactMap { fun.interpreter.evaluate(String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
            return body(interpretedArguments)
        }
    }

    public static func functionWithNamedParameters<T>(_ name: String, body: @escaping ([String: Any]) -> T?) -> Function<T> {
        return Function([Keyword(name), OpenKeyword("("), Variable<String>("arguments", options: .notInterpreted), CloseKeyword(")")]) { fun in
            guard let arguments = fun.variables["arguments"] as? String else { return nil }
            var interpretedArguments: [String: Any] = [:]
            for argument in arguments.split(separator: ",") {
                let parts = String(argument).trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "=")
                if let key = parts.first, let value = parts.last {
                    interpretedArguments[String(key)] = fun.interpreter.evaluate(String(value))
                }
            }
            return body(interpretedArguments)
        }
    }

    public static func objectFunction<O, T>(_ name: String, body: @escaping (O) -> T?) -> Function<T> {
        return Function([Variable<O>("lhs"), Keyword("."), Variable<String>("rhs", options: .notInterpreted) {
            guard let value = $0.value as? String, value == name else { return nil }
            return value
        }], options: .backwardMatch) {
            guard let object = $0.variables["lhs"] as? O, $0.variables["rhs"] != nil else { return nil }
            return body(object)
        }
    }

    public static func objectFunctionWithParameters<O, T>(_ name: String, body: @escaping (O, [Any]) -> T?) -> Function<T> {
        return Function([Variable<O>("lhs"), Keyword("."), Variable<String>("rhs", options: .notInterpreted) {
            guard let value = $0.value as? String, value == name else { return nil }
            return value
        }, OpenKeyword("("), Variable<String>("arguments", options: .notInterpreted), CloseKeyword(")")]) { fun in
            guard let object = fun.variables["lhs"] as? O, fun.variables["rhs"] != nil, let arguments = fun.variables["arguments"] as? String else { return nil }
            let interpretedArguments = arguments.split(separator: ",").compactMap { fun.interpreter.evaluate(String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
            return body(object, interpretedArguments)
        }
    }

    public static func objectFunctionWithNamedParameters<O, T>(_ name: String, body: @escaping (O, [String: Any]) -> T?) -> Function<T> {
        return Function([Variable<O>("lhs"), Keyword("."), Variable<String>("rhs", options: .notInterpreted) {
            guard let value = $0.value as? String, value == name else { return nil }
            return value
        }, OpenKeyword("("), Variable<String>("arguments", options: .notInterpreted), CloseKeyword(")")]) { fun in
            guard let object = fun.variables["lhs"] as? O, fun.variables["rhs"] != nil, let arguments = fun.variables["arguments"] as? String else { return nil }
            var interpretedArguments: [String: Any] = [:]
            for argument in arguments.split(separator: ",") {
                let parts = String(argument).trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "=")
                if let key = parts.first, let value = parts.last {
                    interpretedArguments[String(key)] = fun.interpreter.evaluate(String(value))
                }
            }
            return body(object, interpretedArguments)
        }
    }
}
