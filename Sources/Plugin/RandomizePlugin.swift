import SwiftCompilerPlugin
import SwiftSyntaxMacros
import RandomizerCore
import Foundation

@attached(member, names: named(random))
@attached(extension, conformances: Randomizable)
public macro Randomize() = #externalMacro(module: "Macros", type: "RandomizeMacro")

@attached(peer)
public macro Randomizable(in: Any? = nil, stringStrategy: StringRandomizationStrategy? = nil) = #externalMacro(module: "Macros", type: "RandomizedAttributeMacro")

@attached(peer)
public macro Unrandomizable() = #externalMacro(module: "Macros", type: "UnrandomizedAttributeMacro")

