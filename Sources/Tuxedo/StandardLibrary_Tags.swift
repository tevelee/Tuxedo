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
        return Pattern([Keyword(tagPrefix + " if"), Variable<Bool>("condition"), Keyword(tagSuffix), TemplateVariable("body", options: [.notTrimmed, .notInterpreted]) {
            guard let content = $0.value as? String, !content.contains(tagPrefix + " else " + tagSuffix) else { return nil }
            return content
        }, Keyword("{%"), Keyword("endif"), Keyword("%}")]) {
            guard let condition = $0.variables["condition"] as? Bool, let body = $0.variables["body"] as? String else { return nil }
            if condition {
                return $0.interpreter.evaluate(body, context: $0.context)
            }
            return ""
        }
    }

    static var ifElseStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " if"), Variable<Bool>("condition"), Keyword(tagSuffix), TemplateVariable("body", options: [.notTrimmed, .notInterpreted]) {
            guard let content = $0.value as? String, !content.contains(tagPrefix + " else " + tagSuffix) else { return nil }
            return content
        }, Keyword(tagPrefix + " else " + tagSuffix), TemplateVariable("else", options: [.notTrimmed, .notInterpreted]) {
            guard let content = $0.value as? String, !content.contains(tagPrefix + " else " + tagSuffix) else { return nil }
            return content
        }, CloseKeyword(tagPrefix + " endif " + tagSuffix)]) {
            guard let condition = $0.variables["condition"] as? Bool, let body = $0.variables["body"] as? String else { return nil }
            if condition {
                return $0.interpreter.evaluate(body, context: $0.context)
            } else {
                guard let elseValue = $0.variables["else"] as? String else { return nil }
                return $0.interpreter.evaluate(elseValue, context: $0.context)
            }
        }
    }

    static var printStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword("{{"), Variable<Any>("body"), CloseKeyword("}}")]) {
            guard let body = $0.variables["body"] else { return nil }
            return $0.interpreter.typedInterpreter.print(body)
        }
    }

    static var forInStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " for"),
                        GenericVariable<String, StringTemplateInterpreter>("variable", options: .notInterpreted), Keyword("in"),
                        Variable<[Any]>("items"),
                        Keyword(tagSuffix),
                        GenericVariable<String, StringTemplateInterpreter>("body", options: [.notInterpreted, .notTrimmed]),
                        CloseKeyword(tagPrefix + " endfor " + tagSuffix)]) { fun in
                            guard let variableName = fun.variables["variable"] as? String,
                                let items = fun.variables["items"] as? [Any],
                                let body = fun.variables["body"] as? String else { return nil }
                            var result = ""
                            fun.context.push()
                            fun.context.variables["__loop"] = items
                            for (index, item) in items.enumerated() {
                                fun.context.variables["__first"] = index == items.startIndex
                                fun.context.variables["__last"] = index == items.index(before: items.endIndex)
                                fun.context.variables[variableName] = item
                                result += fun.interpreter.evaluate(body, context: fun.context)
                            }
                            fun.context.pop()
                            return result
        }
    }

    static var setStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " set"), TemplateVariable("variable"), Keyword(tagSuffix), TemplateVariable("body"), CloseKeyword(tagPrefix + " endset " + tagSuffix)]) {
            guard let variableName = $0.variables["variable"] as? String, let body = $0.variables["body"] as? String else { return nil }
            $0.interpreter.context.variables[variableName] = body
            return ""
        }
    }

    static var setUsingBodyStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " set"), TemplateVariable("variable"), Keyword("="), Variable<Any>("value"), CloseKeyword(tagSuffix)]) {
            guard let variableName = $0.variables["variable"] as? String else { return nil }
            $0.interpreter.context.variables[variableName] = $0.variables["value"]
            return ""
        }
    }

    static var blockStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " block"),
                        GenericVariable<String, StringTemplateInterpreter>("name", options: .notInterpreted),
                        Keyword(tagSuffix),
                        GenericVariable<String, StringTemplateInterpreter>("body", options: .notInterpreted),
                        CloseKeyword(tagPrefix + " endblock " + tagSuffix)]) { fun in
                            guard let name = fun.variables["name"] as? String, let body = fun.variables["body"] as? String else { return nil }
                            let block: BlockRenderer = { context in
                                context.push()
                                context.merge(with: fun.context) { existing, _ in existing }
                                context.variables["__block"] = name
                                if let last = context.blocks[name] {
                                    context.blocks[name] = Array(last.dropLast())
                                }
                                let result = fun.interpreter.evaluate(body, context: context)
                                context.pop()
                                return result
                            }
                            if let last = fun.interpreter.context.blocks[name] {
                                fun.interpreter.context.blocks[name] = last + [block]
                                return ""
                            } else {
                                fun.interpreter.context.blocks[name] = [block]
                                return "{{{\(name)}}}"
                            }
        }
    }

    static var macroStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " macro"), GenericVariable<String, StringTemplateInterpreter>("name", options: .notInterpreted), Keyword("("), GenericVariable<[String], StringTemplateInterpreter>("arguments", options: .notInterpreted) {
            guard let arguments = $0.value as? String else { return nil }
            return arguments.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }, Keyword(")"), Keyword(tagSuffix), GenericVariable<String, StringTemplateInterpreter>("body", options: .notInterpreted), CloseKeyword(tagPrefix + " endmacro " + tagSuffix)]) { fun in
            guard let name = fun.variables["name"] as? String,
                let arguments = fun.variables["arguments"] as? [String],
                let body = fun.variables["body"] as? String else { return nil }
            fun.interpreter.context.macros[name] = (arguments: arguments, body: body)
            return ""
        }
    }

    static var commentStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword("{#"), GenericVariable<String, StringTemplateInterpreter>("body", options: .notInterpreted), CloseKeyword("#}")]) { _ in "" }
    }

    static var importStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " import"), Variable<String>("file"), CloseKeyword(tagSuffix)]) {
            guard let file = $0.variables["file"] as? String,
                let url = Bundle.allBundles.compactMap({ $0.url(forResource: file, withExtension: nil) }).first,
                let expression = try? String(contentsOf: url) else { return nil }
            return $0.interpreter.evaluate(expression, context: $0.context)
        }
    }

    static var spacelessStatement: Pattern<String, TemplateInterpreter<String>> {
        return Pattern([OpenKeyword(tagPrefix + " spaceless " + tagSuffix), TemplateVariable("body"), CloseKeyword(tagPrefix + " endspaceless " + tagSuffix)]) {
            guard let body = $0.variables["body"] as? String else { return nil }
            return body.self.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined()
        }
    }
}
