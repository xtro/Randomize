import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct RandomizePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RandomizeMacro.self,
        RandomizedAttributeMacro.self,
        UnrandomizedAttributeMacro.self
    ]
}
