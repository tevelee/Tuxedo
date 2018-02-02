import Foundation

extension StandardLibrary {
    public static var functions: [FunctionProtocol] {
        return [
            parentheses,
            macro,
            blockParent,
            ternaryOperator,
            
            rangeFunction,
            rangeOfStringFunction,
            rangeBySteps,
            
            loopIsFirst,
            loopIsLast,
            loopIsNotFirst,
            loopIsNotLast,
            
            startsWithOperator,
            endsWithOperator,
            containsOperator,
            matchesOperator,
            capitalise,
            lowercase,
            uppercase,
            lowercaseFirst,
            uppercaseFirst,
            trim,
            urlEncode,
            urlDecode,
            escape,
            nl2br,
            
            stringConcatenationOperator,
            
            multiplicationOperator,
            divisionOperator,
            additionOperator,
            subtractionOperator,
            moduloOperator,
            powOperator,
            
            lessThanOperator,
            lessThanOrEqualsOperator,
            moreThanOperator,
            moreThanOrEqualsOperator,
            equalsOperator,
            notEqualsOperator,
            
            stringEqualsOperator,
            stringNotEqualsOperator,
            
            inNumericArrayOperator,
            inStringArrayOperator,
            
            incrementOperator,
            decrementOperator,
            
            negationOperator,
            notOperator,
            orOperator,
            andOperator,
            
            absoluteValue,
            defaultValue,
            
            isEvenOperator,
            isOddOperator,
            
            minFunction,
            maxFunction,
            sumFunction,
            sqrtFunction,
            roundFunction,
            averageFunction,
            
            arraySubscript,
            arrayCountFunction,
            arrayMapFunction,
            arrayFilterFunction,
            arraySortFunction,
            arrayReverseFunction,
            arrayMinFunction,
            arrayMaxFunction,
            arrayFirstFunction,
            arrayLastFunction,
            arrayJoinFunction,
            arraySplitFunction,
            arrayMergeFunction,
            arraySumFunction,
            arrayAverageFunction,
            
            dictionarySubscript,
            dictionaryCountFunction,
            dictionaryFilterFunction,
            dictionaryKeys,
            dictionaryValues,
            
            dateFactory,
            dateFormat,
            
            stringFactory
        ]
    }
    
    public static var parentheses: Function<Any> {
        return Function([OpenKeyword("("), Variable<Any>("body"), CloseKeyword(")")]) { arguments, _, _ in arguments["body"] }
    }
    
    public static var macro: Function<Any> {
        return Function([Variable<String>("name", options: .notInterpreted) { value, interpreter in
            guard let value = value as? String else { return nil }
            return interpreter.context.macros.keys.contains(value) ? value : nil
            }, OpenKeyword("("), Variable<String>("arguments", options: .notInterpreted), CloseKeyword(")")]) { variables, interpreter, context in
                guard let arguments = variables["arguments"] as? String,
                    let name = variables["name"] as? String,
                    let macro = interpreter.context.macros[name.trimmingCharacters(in: .whitespacesAndNewlines)] else { return nil }
                let interpretedArguments = arguments.split(separator: ",").flatMap { interpreter.evaluate(String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
                context.push()
                for (key, value) in zip(macro.arguments, interpretedArguments) {
                    context.variables[key] = value
                }
                let result = interpreter.evaluate(macro.body, context: context)
                context.pop()
                return result
        }
    }
    
    public static var blockParent: Function<Any> {
        return Function([Keyword("parent"), OpenKeyword("("), Variable<String>("arguments", options: .notInterpreted), CloseKeyword(")")]) { variables, interpreter, context in
            guard let arguments = variables["arguments"] as? String else { return nil }
            var interpretedArguments: [String: Any] = [:]
            for argument in arguments.split(separator: ",") {
                let parts = String(argument).trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "=")
                if let key = parts.first, let value = parts.last {
                    interpretedArguments[String(key)] = interpreter.evaluate(String(value))
                }
            }
            guard let name = context.variables["__block"] as? String, let block = context.blocks[name]?.last else { return nil }
            context.push()
            context.variables.merge(interpretedArguments) { _, new in new }
            let result = block(context)
            context.pop()
            return result
        }
    }
    
    public static var ternaryOperator: Function<Any> {
        return Function([Variable<Bool>("condition"), Keyword("?"), Variable<Any>("body"), Keyword(": "), Variable<Any>("else")]) { arguments, _, _ in
            guard let condition = arguments["condition"] as? Bool else { return nil }
            return condition ? arguments["body"] : arguments["else"]
        }
    }
    
    public static var rangeFunction: Function<[Double]> {
        return infixOperator("...") { (lhs: Double, rhs: Double) in
            CountableClosedRange(uncheckedBounds: (lower: Int(lhs), upper: Int(rhs))).map { Double($0) }
        }
    }
    
    public static var rangeOfStringFunction: Function<[String]> {
        return infixOperator("...") { (lhs: String, rhs: String) in
            CountableClosedRange(uncheckedBounds: (lower: Character(lhs), upper: Character(rhs))).map { String($0) }
        }
    }
    
    public static var startsWithOperator: Function<Bool> {
        return infixOperator("starts with") { (lhs: String, rhs: String) in lhs.hasPrefix(rhs) }
    }
    
    public static var endsWithOperator: Function<Bool> {
        return infixOperator("ends with") { (lhs: String, rhs: String) in lhs.hasSuffix(rhs) }
    }
    
    public static var containsOperator: Function<Bool> {
        return infixOperator("contains") { (lhs: String, rhs: String) in lhs.contains(rhs) }
    }
    
    public static var matchesOperator: Function<Bool> {
        return infixOperator("matches") { (lhs: String, rhs: String) in
            if let regex = try? NSRegularExpression(pattern: rhs) {
                let matches = regex.numberOfMatches(in: lhs, range: NSRange(lhs.startIndex..., in: lhs))
                return matches > 0
            }
            return false
        }
    }
    
    public static var capitalise: Function<String> {
        return objectFunction("capitalise") { (value: String) -> String? in value.capitalized }
    }
    
    public static var lowercase: Function<String> {
        return objectFunction("lower") { (value: String) -> String? in value.lowercased() }
    }
    
    public static var uppercase: Function<String> {
        return objectFunction("upper") { (value: String) -> String? in value.uppercased() }
    }
    
    public static var lowercaseFirst: Function<String> {
        return objectFunction("lowerFirst") { (value: String) -> String? in
            guard let first = value.first else { return nil }
            return String(first).lowercased() + value[value.index(value.startIndex, offsetBy: 1)...]
        }
    }
    
    public static var uppercaseFirst: Function<String> {
        return objectFunction("upperFirst") { (value: String) -> String? in
            guard let first = value.first else { return nil }
            return String(first).uppercased() + value[value.index(value.startIndex, offsetBy: 1)...]
        }
    }
    
    public static var trim: Function<String> {
        return objectFunction("trim") { (value: String) -> String? in value.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    public static var urlEncode: Function<String> {
        return objectFunction("urlEncode") { (value: String) -> String? in value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) }
    }
    
    public static var urlDecode: Function<String> {
        return objectFunction("urlDecode") { (value: String) -> String? in value.removingPercentEncoding }
    }
    
    public static var escape: Function<String> {
        return objectFunction("escape") { (value: String) -> String? in value.html }
    }
    
    public static var nl2br: Function<String> {
        return objectFunction("nl2br") { (value: String) -> String? in value
            .replacingOccurrences(of: "\r\n", with: "<br/>")
            .replacingOccurrences(of: "\n", with: "<br/>")
        }
    }
    
    public static var stringConcatenationOperator: Function<String> {
        return infixOperator("+") { (lhs: String, rhs: String) in lhs + rhs }
    }
    
    public static var additionOperator: Function<Double> {
        return infixOperator("+") { (lhs: Double, rhs: Double) in lhs + rhs }
    }
    
    public static var subtractionOperator: Function<Double> {
        return infixOperator("-") { (lhs: Double, rhs: Double) in lhs - rhs }
    }
    
    public static var multiplicationOperator: Function<Double> {
        return infixOperator("*") { (lhs: Double, rhs: Double) in lhs * rhs }
    }
    
    public static var divisionOperator: Function<Double> {
        return infixOperator("/") { (lhs: Double, rhs: Double) in lhs / rhs }
    }
    
    public static var moduloOperator: Function<Double> {
        return infixOperator("%") { (lhs: Double, rhs: Double) in Double(Int(lhs) % Int(rhs)) }
    }
    
    public static var powOperator: Function<Double> {
        return infixOperator("**") { (lhs: Double, rhs: Double) in pow(lhs, rhs) }
    }
    
    public static var lessThanOperator: Function<Bool> {
        return infixOperator("<") { (lhs: Double, rhs: Double) in lhs < rhs }
    }
    
    public static var moreThanOperator: Function<Bool> {
        return infixOperator("<=") { (lhs: Double, rhs: Double) in lhs <= rhs }
    }
    
    public static var lessThanOrEqualsOperator: Function<Bool> {
        return infixOperator(">") { (lhs: Double, rhs: Double) in lhs > rhs }
    }
    
    public static var moreThanOrEqualsOperator: Function<Bool> {
        return infixOperator(">=") { (lhs: Double, rhs: Double) in lhs >= rhs }
    }
    
    public static var equalsOperator: Function<Bool> {
        return infixOperator("==") { (lhs: Double, rhs: Double) in lhs == rhs }
    }
    
    public static var notEqualsOperator: Function<Bool> {
        return infixOperator("!=") { (lhs: Double, rhs: Double) in lhs != rhs }
    }
    
    public static var stringEqualsOperator: Function<Bool> {
        return infixOperator("==") { (lhs: String, rhs: String) in lhs == rhs }
    }
    
    public static var stringNotEqualsOperator: Function<Bool> {
        return infixOperator("!=") { (lhs: String, rhs: String) in lhs != rhs }
    }
    
    public static var inStringArrayOperator: Function<Bool> {
        return infixOperator("in") { (lhs: String, rhs: [String]) in rhs.contains(lhs) }
    }
    
    public static var inNumericArrayOperator: Function<Bool> {
        return infixOperator("in") { (lhs: Double, rhs: [Double]) in rhs.contains(lhs) }
    }
    
    public static var negationOperator: Function<Bool> {
        return prefixOperator("!") { (expression: Bool) in !expression }
    }
    
    public static var notOperator: Function<Bool> {
        return prefixOperator("not") { (expression: Bool) in !expression }
    }
    
    public static var andOperator: Function<Bool> {
        return infixOperator("and") { (lhs: Bool, rhs: Bool) in lhs && rhs }
    }
    
    public static var orOperator: Function<Bool> {
        return infixOperator("or") { (lhs: Bool, rhs: Bool) in lhs || rhs }
    }
    
    public static var absoluteValue: Function<Double> {
        return objectFunction("abs") { (value: Double) -> Double? in abs(value) }
    }
    
    public static var defaultValue: Function<Any> {
        return Function([Variable<Any>("lhs"), Keyword("."), Variable<String>("rhs", options: .notInterpreted) { value, _ in
            guard let value = value as? String, value == "default" else { return nil }
            return value
            }, Keyword("("), Variable<Any>("fallback"), Keyword(")")], options: .backwardMatch) { variables, _, _ in
                guard let value = variables["lhs"], variables["rhs"] != nil else { return nil }
                return isNilOrWrappedNil(value: value) ? variables["fallback"] : value
        }
    }
    
    public static var incrementOperator: Function<Double> {
        return suffixOperator("++") { (expression: Double) in expression + 1 }
    }
    
    public static var decrementOperator: Function<Double> {
        return suffixOperator("--") { (expression: Double) in expression - 1 }
    }
    
    public static var isEvenOperator: Function<Bool> {
        return suffixOperator("is even") { (expression: Double) in Int(expression) % 2 == 0 }
    }
    
    public static var isOddOperator: Function<Bool> {
        return suffixOperator("is odd") { (expression: Double) in abs(Int(expression) % 2) == 1 }
    }
    
    public static var minFunction: Function<Double> {
        return function("min") { (arguments: [Any]) -> Double? in
            guard let arguments = arguments as? [Double] else { return nil }
            return arguments.min()
        }
    }
    
    public static var maxFunction: Function<Double> {
        return function("max") { (arguments: [Any]) -> Double? in
            guard let arguments = arguments as? [Double] else { return nil }
            return arguments.max()
        }
    }
    
    public static var arraySortFunction: Function<[Double]> {
        return objectFunction("sort") { (object: [Double]) -> [Double]? in object.sorted() }
    }
    
    public static var arrayReverseFunction: Function<[Double]> {
        return objectFunction("reverse") { (object: [Double]) -> [Double]? in object.reversed() }
    }
    
    public static var arrayMinFunction: Function<Double> {
        return objectFunction("min") { (object: [Double]) -> Double? in object.min() }
    }
    
    public static var arrayMaxFunction: Function<Double> {
        return objectFunction("max") { (object: [Double]) -> Double? in object.max() }
    }
    
    public static var arrayFirstFunction: Function<Double> {
        return objectFunction("first") { (object: [Double]) -> Double? in object.first }
    }
    
    public static var arrayLastFunction: Function<Double> {
        return objectFunction("last") { (object: [Double]) -> Double? in object.last }
    }
    
    public static var arrayJoinFunction: Function<String> {
        return objectFunctionWithParameters("join") { (object: [String], arguments: [Any]) -> String? in
            guard let separator = arguments.first as? String else { return nil }
            return object.joined(separator: separator)
        }
    }
    
    public static var arraySplitFunction: Function<[String]> {
        return Function([Variable<String>("lhs"), Keyword("."), Variable<String>("rhs", options: .notInterpreted) { value, _ in
            guard let value = value as? String, value == "split" else { return nil }
            return value
            }, Keyword("("), Variable<String>("separator"), Keyword(")")]) { variables, _, _ in
                guard let object = variables["lhs"] as? String, variables["rhs"] != nil, let separator = variables["separator"] as? String else { return nil }
                return object.split(separator: Character(separator)).map { String($0) }
        }
    }
    
    public static var arrayMergeFunction: Function<[Any]> {
        return Function([Variable<[Any]>("lhs"), Keyword("."), Variable<String>("rhs", options: .notInterpreted) { value, _ in
            guard let value = value as? String, value == "merge" else { return nil }
            return value
            }, Keyword("("), Variable<[Any]>("other"), Keyword(")")]) { variables, _, _ in
                guard let object = variables["lhs"] as? [Any], variables["rhs"] != nil, let other = variables["other"] as? [Any] else { return nil }
                return object + other
        }
    }
    
    public static var arraySumFunction: Function<Double> {
        return objectFunction("sum") { (object: [Double]) -> Double? in object.reduce(0, +) }
    }
    
    public static var arrayAverageFunction: Function<Double> {
        return objectFunction("avg") { (object: [Double]) -> Double? in object.reduce(0, +) / Double(object.count) }
    }
    
    public static var arrayCountFunction: Function<Double> {
        return objectFunction("count") { (object: [Double]) -> Double? in Double(object.count) }
    }
    
    public static var dictionaryCountFunction: Function<Double> {
        return objectFunction("count") { (object: [String: Any]) -> Double? in Double(object.count) }
    }
    
    public static var arrayMapFunction: Function<[Any]> {
        return Function([Variable<[Any]>("lhs"), Keyword("."), Variable<String>("rhs", options: .notInterpreted) { value, _ in
            guard let value = value as? String, value == "map" else { return nil }
            return value
            }, Keyword("("), Variable<String>("variable", options: .notInterpreted), Keyword("=>"), Variable<Any>("body", options: .notInterpreted), Keyword(")")]) { variables, interpreter, context in
                guard let object = variables["lhs"] as? [Any], variables["rhs"] != nil,
                    let variable = variables["variable"] as? String,
                    let body = variables["body"] as? String else { return nil }
                context.push()
                let result: [Any] = object.flatMap { item in
                    context.variables[variable] = item
                    return interpreter.evaluate(body, context: context)
                }
                context.pop()
                return result
        }
    }
    
    public static var arrayFilterFunction: Function<[Any]> {
        return Function([Variable<[Any]>("lhs"), Keyword("."), Variable<String>("rhs", options: .notInterpreted) { value, _ in
            guard let value = value as? String, value == "filter" else { return nil }
            return value
            }, Keyword("("), Variable<String>("variable", options: .notInterpreted), Keyword("=>"), Variable<Any>("body", options: .notInterpreted), Keyword(")")]) { variables, interpreter, context in
                guard let object = variables["lhs"] as? [Any], variables["rhs"] != nil,
                    let variable = variables["variable"] as? String,
                    let body = variables["body"] as? String else { return nil }
                context.push()
                let result: [Any] = object.filter { item in
                    context.variables[variable] = item
                    if let result = interpreter.evaluate(body, context: context) as? Bool {
                        return result
                    }
                    return false
                }
                context.pop()
                return result
        }
    }
    
    public static var dictionaryFilterFunction: Function<[String: Any]> {
        return Function([Variable<[String: Any]>("lhs"), Keyword("."), Variable<String>("rhs", options: .notInterpreted) { value, _ in
            guard let value = value as? String, value == "filter" else { return nil }
            return value
            }, Keyword("("), Variable<String>("key", options: .notInterpreted), Keyword(","), Variable<String>("value", options: .notInterpreted), Keyword("=>"), Variable<Any>("body", options: .notInterpreted), Keyword(")")]) { variables, interpreter, context in
                guard let object = variables["lhs"] as? [String: Any], variables["rhs"] != nil,
                    let keyVariable = variables["key"] as? String,
                    let valueVariable = variables["value"] as? String,
                    let body = variables["body"] as? String else { return nil }
                context.push()
                let result: [String: Any] = object.filter { key, value in
                    context.variables[keyVariable] = key
                    context.variables[valueVariable] = value
                    if let result = interpreter.evaluate(body, context: context) as? Bool {
                        return result
                    }
                    return false
                }
                context.pop()
                return result
        }
    }
    
    public static var sumFunction: Function<Double> {
        return function("sum") { (arguments: [Any]) -> Double? in
            guard let arguments = arguments as? [Double] else { return nil }
            return arguments.reduce(0, +)
        }
    }
    
    public static var averageFunction: Function<Double> {
        return function("avg") { (arguments: [Any]) -> Double? in
            guard let arguments = arguments as? [Double] else { return nil }
            return arguments.reduce(0, +) / Double(arguments.count)
        }
    }
    
    public static var sqrtFunction: Function<Double> {
        return function("sqrt") { (arguments: [Any]) -> Double? in
            guard let value = arguments.first as? Double else { return nil }
            return sqrt(value)
        }
    }
    
    public static var roundFunction: Function<Double> {
        return function("round") { (arguments: [Any]) -> Double? in
            guard let value = arguments.first as? Double else { return nil }
            return round(value)
        }
    }
    
    public static var dateFactory: Function<Date?> {
        return function("Date") { (arguments: [Any]) -> Date? in
            guard let arguments = arguments as? [Double], arguments.count >= 3 else { return nil }
            var components = DateComponents()
            components.calendar = Calendar(identifier: .gregorian)
            components.year = Int(arguments[0])
            components.month = Int(arguments[1])
            components.day = Int(arguments[2])
            components.hour = arguments.count > 3 ? Int(arguments[3]) : 0
            components.minute = arguments.count > 4 ? Int(arguments[4]) : 0
            components.second = arguments.count > 5 ? Int(arguments[5]) : 0
            return components.date
        }
    }
    
    public static var stringFactory: Function<String?> {
        return function("String") { (arguments: [Any]) -> String? in
            guard let argument = arguments.first as? Double else { return nil }
            return String(format: "%g", argument)
        }
    }
    
    public static var rangeBySteps: Function<[Double]> {
        return functionWithNamedParameters("range") { (arguments: [String: Any]) -> [Double]? in
            guard let start = arguments["start"] as? Double, let end = arguments["end"] as? Double, let step = arguments["step"] as? Double else { return nil }
            var result = [start]
            var value = start
            while value <= end - step {
                value += step
                result.append(value)
            }
            return result
        }
    }
    
    public static var loopIsFirst: Function<Bool?> {
        return Function([Variable<Any>("value"), Keyword("is first")]) { _, _, context in
            return context.variables["__first"] as? Bool
        }
    }
    
    public static var loopIsLast: Function<Bool?> {
        return Function([Variable<Any>("value"), Keyword("is last")]) { _, _, context in
            return context.variables["__last"] as? Bool
        }
    }
    
    public static var loopIsNotFirst: Function<Bool?> {
        return Function([Variable<Any>("value"), Keyword("is not first")]) { _, _, context in
            guard let isFirst = context.variables["__first"] as? Bool else { return nil }
            return !isFirst
        }
    }
    
    public static var loopIsNotLast: Function<Bool?> {
        return Function([Variable<Any>("value"), Keyword("is not last")]) { _, _, context in
            guard let isLast = context.variables["__last"] as? Bool else { return nil }
            return !isLast
        }
    }
    
    public static var dateFormat: Function<String> {
        return objectFunctionWithParameters("format") { (object: Date, arguments: [Any]) -> String? in
            guard let format = arguments.first as? String else { return nil }
            let dateFormatter = DateFormatter(with: format)
            return dateFormatter.string(from: object)
        }
    }
    
    public static var arraySubscript: Function<Any?> {
        return Function([Variable<[Any]>("array"), Keyword("."), Variable<Double>("index")]) { variables, _, _ in
            guard let array = variables["array"] as? [Any], let index = variables["index"] as? Double, index > 0, Int(index) < array.count else { return nil }
            return array[Int(index)]
        }
    }
    
    public static var dictionarySubscript: Function<Any?> {
        return Function([Variable<[String: Any]>("dictionary"), Keyword("."), Variable<String>("key", options: .notInterpreted)]) { variables, _, _ in
            guard let dictionary = variables["dictionary"] as? [String: Any], let key = variables["key"] as? String else { return nil }
            return dictionary[key]
        }
    }
    
    public static var dictionaryKeys: Function<[String]> {
        return objectFunction("keys") { (object: [String: Any?]) -> [String] in
            return object.keys.sorted()
        }
    }
    
    public static var dictionaryValues: Function<[Any?]> {
        return objectFunction("values") { (object: [String: Any?]) -> [Any?] in
            if let values = object as? [String: Double] {
                return values.values.sorted()
            }
            if let values = object as? [String: String] {
                return values.values.sorted()
            }
            return Array(object.values)
        }
    }
    
    public static var methodCallWithIntResult: Function<Double> {
        return Function([Variable<Any>("lhs"), Keyword("."), Variable<String>("rhs", options: .notInterpreted)]) { (arguments, _, _) -> Double? in
            if let lhs = arguments["lhs"] as? NSObjectProtocol,
                let rhs = arguments["rhs"] as? String,
                let result = lhs.perform(Selector(rhs)) {
                return Double(Int(bitPattern: result.toOpaque()))
            }
            return nil
        }
    }
}
