import Foundation

public extension StandardLibrary {
    static var dataTypes: [DataTypeProtocol] {
        return [
            stringType,
            booleanType,
            arrayType,
            dictionaryType,
            dateType,
            numericType,
            emptyType
        ]
    }

    static var numericType: DataType<Double> {
        let numberLiteral = Literal { value, _ in Double(value) }
        let pi = Literal("pi", convertsTo: Double.pi)
        return DataType(type: Double.self, literals: [numberLiteral, pi]) { value, _ in String(format: "%g", value) }
    }

    static var stringType: DataType<String> {
        let singleQuotesLiteral = literal(opening: "'", closing: "'") { (input, _) in input }
        return DataType(type: String.self, literals: [singleQuotesLiteral]) { value, _ in value }
    }

    static var dateType: DataType<Date> {
        let dateFormatter = DateFormatter(with: "yyyy-MM-dd HH:mm:ss")
        let now = Literal<Date>("now", convertsTo: Date())
        return DataType(type: Date.self, literals: [now]) { value, _ in dateFormatter.string(from: value) }
    }

    static var arrayType: DataType<[CustomStringConvertible]> {
        let arrayLiteral = literal(opening: "[", closing: "]") { input, interpreter -> [CustomStringConvertible]? in
            return input
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { interpreter.evaluate(String($0)) as? CustomStringConvertible ?? String($0) }
        }
        return DataType(type: [CustomStringConvertible].self, literals: [arrayLiteral]) { value, printer in value.map { printer.print($0) }.joined(separator: ",") }
    }

    static var dictionaryType: DataType<[String: CustomStringConvertible?]> {
        let dictionaryLiteral = literal(opening: "{", closing: "}") { input, interpreter -> [String: CustomStringConvertible?]? in
            let values = input
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            let parsedValues : [(key: String, value: CustomStringConvertible?)] = values
                .map { $0.split(separator: ":").map { interpreter.evaluate(String($0)) } }
                .flatMap {
                    guard let first = $0.first, let key = first as? String, let value = $0.last else { return nil }
                    return (key: key, value: value as? CustomStringConvertible)
                }
            return Dictionary(grouping: parsedValues) { $0.key }.mapValues { $0.first?.value }
        }
        return DataType(type: [String: CustomStringConvertible?].self, literals: [dictionaryLiteral]) { value, printer in
            let items = value.map { key, value in
                if let value = value {
                    return "\(printer.print(key)): \(printer.print(value))"
                } else {
                    return "\(printer.print(key)): nil"
                }
            }.sorted().joined(separator: ", ")
            return "[\(items)]"
        }
    }

    static var booleanType: DataType<Bool> {
        let trueLiteral = Literal("true", convertsTo: true)
        let falseLiteral = Literal("false", convertsTo: false)
        return DataType(type: Bool.self, literals: [trueLiteral, falseLiteral]) { value, _ in value ? "true" : "false" }
    }

    static var emptyType: DataType<Any?> {
        let nullLiteral = Literal<Any?>("null", convertsTo: nil)
        let nilLiteral = Literal<Any?>("nil", convertsTo: nil)
        return DataType(type: Any?.self, literals: [nullLiteral, nilLiteral]) { _, _ in "null" }
    }
}
