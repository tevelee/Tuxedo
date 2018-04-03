import Foundation

internal typealias Macro = (arguments: [String], body: String)
internal typealias BlockRenderer = (_ context: Context) -> String

extension Context {
    static let macrosKey: String = "__macros"
    var macros: [String: Macro] {
        get {
            return variables[Context.macrosKey] as? [String: Macro] ?? [:]
        }
        set {
            variables[Context.macrosKey] = macros.merging(newValue) { _, new in new }
        }
    }

    static let blocksKey: String = "__blocks"
    var blocks: [String: [BlockRenderer]] {
        get {
            return variables[Context.blocksKey] as? [String: [BlockRenderer]] ?? [:]
        }
        set {
            variables[Context.blocksKey] = blocks.merging(newValue) { _, new in new }
        }
    }
}
