import Foundation

public extension StandardLibrary {
    static var tags: [Pattern<String, TemplateInterpreter<String>>] {
        return [
            ifElseStatement,
            ifStatement,
            printStatement,
            forInStatement,
            setUsingBodyStatement,
            setStatement,
            blockStatement,
            macroStatement,
            commentStatement,
            importStatement,
            spacelessStatement
        ]
    }

    static var tagPrefix: String = "{%"
    static var tagSuffix: String = "%}"

    static var ifStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([Keyword(tagPrefix + " if"), Variable<Bool>("condition"), Keyword(tagSuffix), TemplateVariable("body", options: .notTrimmed) { value, _ in
            guard let content = value as? String, !content.contains(tagPrefix + " else " + tagSuffix) else { return nil }
            return content
        }, Keyword("{%"), Keyword("endif"), Keyword("%}")]) { variables, _, _ in
            guard let condition = variables["condition"] as? Bool, let body = variables["body"] as? String else { return nil }
            if condition {
                return body
            }
            return ""
        }
    }

    static var ifElseStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " if"), Variable<Bool>("condition"), Keyword(tagSuffix), TemplateVariable("body", options: .notTrimmed) { value, _ in
            guard let content = value as? String, !content.contains(tagPrefix + " else " + tagSuffix) else { return nil }
            return content
        }, Keyword(tagPrefix + " else " + tagSuffix), TemplateVariable("else", options: .notTrimmed) { value, _ in
            guard let content = value as? String, !content.contains(tagPrefix + " else " + tagSuffix) else { return nil }
            return content
        }, CloseKeyword(tagPrefix + " endif " + tagSuffix)]) { variables, _, _ in
            guard let condition = variables["condition"] as? Bool, let body = variables["body"] as? String else { return nil }
            if condition {
                return body
            } else {
                return variables["else"] as? String
            }
        }
    }

    static var printStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword("{{"), Variable<Any>("body"), CloseKeyword("}}")]) { variables, interpreter, _ in
            guard let body = variables["body"] else { return nil }
            return interpreter.typedInterpreter.print(body)
        }
    }

    static var forInStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " for"),
                        GenericVariable<String, StringTemplateInterpreter>("variable", options: .notInterpreted), Keyword("in"),
                        Variable<[Any]>("items"),
                        Keyword(tagSuffix),
                        GenericVariable<String, StringTemplateInterpreter>("body", options: [.notInterpreted, .notTrimmed]),
                        CloseKeyword(tagPrefix + " endfor " + tagSuffix)]) { variables, interpreter, context in
                            guard let variableName = variables["variable"] as? String,
                                let items = variables["items"] as? [Any],
                                let body = variables["body"] as? String else { return nil }
                            var result = ""
                            context.push()
                            context.variables["__loop"] = items
                            for (index, item) in items.enumerated() {
                                context.variables["__first"] = index == items.startIndex
                                context.variables["__last"] = index == items.index(before: items.endIndex)
                                context.variables[variableName] = item
                                result += interpreter.evaluate(body, context: context)
                            }
                            context.pop()
                            return result
        }
    }

    static var setStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " set"), TemplateVariable("variable"), Keyword(tagSuffix), TemplateVariable("body"), CloseKeyword(tagPrefix + " endset " + tagSuffix)]) { variables, interpreter, context in
            guard let variableName = variables["variable"] as? String, let body = variables["body"] as? String else { return nil }
            interpreter.context.variables[variableName] = body
            return ""
        }
    }

    static var setUsingBodyStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " set"), TemplateVariable("variable"), Keyword("="), Variable<Any>("value"), CloseKeyword(tagSuffix)]) { variables, interpreter, context in
            guard let variableName = variables["variable"] as? String else { return nil }
            interpreter.context.variables[variableName] = variables["value"]
            return ""
        }
    }

    static var blockStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " block"),
                        GenericVariable<String, StringTemplateInterpreter>("name", options: .notInterpreted),
                        Keyword(tagSuffix),
                        GenericVariable<String, StringTemplateInterpreter>("body", options: .notInterpreted),
                        CloseKeyword(tagPrefix + " endblock " + tagSuffix)]) { variables, interpreter, localContext in
                            guard let name = variables["name"] as? String, let body = variables["body"] as? String else { return nil }
                            let block: BlockRenderer = { context in
                                context.push()
                                context.merge(with: localContext) { existing, _ in existing }
                                context.variables["__block"] = name
                                if let last = context.blocks[name] {
                                    context.blocks[name] = Array(last.dropLast())
                                }
                                let result = interpreter.evaluate(body, context: context)
                                context.pop()
                                return result
                            }
                            if let last = interpreter.context.blocks[name] {
                                interpreter.context.blocks[name] = last + [block]
                                return ""
                            } else {
                                interpreter.context.blocks[name] = [block]
                                return "{{{\(name)}}}"
                            }
        }
    }

    static var macroStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " macro"), GenericVariable<String, StringTemplateInterpreter>("name", options: .notInterpreted), Keyword("("), GenericVariable<[String], StringTemplateInterpreter>("arguments", options: .notInterpreted) { arguments, _ in
            guard let arguments = arguments as? String else { return nil }
            return arguments.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }, Keyword(")"), Keyword(tagSuffix), GenericVariable<String, StringTemplateInterpreter>("body", options: .notInterpreted), CloseKeyword(tagPrefix + " endmacro " + tagSuffix)]) { variables, interpreter, context in
            guard let name = variables["name"] as? String,
                let arguments = variables["arguments"] as? [String],
                let body = variables["body"] as? String else { return nil }
            interpreter.context.macros[name] = (arguments: arguments, body: body)
            return ""
        }
    }

    static var commentStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword("{#"), GenericVariable<String, StringTemplateInterpreter>("body", options: .notInterpreted), CloseKeyword("#}")]) { _, _, _ in "" }
    }

    static var importStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " import"), Variable<String>("file"), CloseKeyword(tagSuffix)]) { variables, interpreter, context in
            guard let file = variables["file"] as? String,
                let url = Bundle.allBundles.compactMap({ $0.url(forResource: file, withExtension: nil) }).first,
                let expression = try? String(contentsOf: url) else { return nil }
            return interpreter.evaluate(expression, context: context)
        }
    }

    static var spacelessStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " spaceless " + tagSuffix), TemplateVariable("body"), CloseKeyword(tagPrefix + " endspaceless " + tagSuffix)]) { variables, _, _ in
            guard let body = variables["body"] as? String else { return nil }
            return body.self.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined()
        }
    }
}
