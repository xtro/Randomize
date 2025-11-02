import SwiftCompilerPlugin
import SwiftSyntaxMacros
import RandomizerCore
import Foundation

@attached(member, names: named(random))
@attached(extension, conformances: Randomizable)
public macro Randomize() = #externalMacro(module: "RandomizeMacros", type: "RandomizeMacro")

@attached(peer)
public macro Randomizable<T>(in: Range<T>? = nil, strategy: RandomizationStrategy<T>? = nil) = #externalMacro(module: "RandomizeMacros", type: "RandomizedAttributeMacro")

@attached(peer)
public macro Unrandomizable() = #externalMacro(module: "RandomizeMacros", type: "UnrandomizedAttributeMacro")

