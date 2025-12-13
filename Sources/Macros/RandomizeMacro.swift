import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

private struct CaseInfo { let name: String; let params: [(type: String, label: String?)]; let caseRanges: [String?] }

public enum RandomDiag {
    public static let domain = "Randomize"
}

public struct RandomizedAttributeMacro: PeerMacro {
    // This macro is only a marker attribute; it doesn't expand by itself.
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return []
    }
}

public struct UnrandomizedAttributeMacro: PeerMacro {
    // This macro is only a marker attribute; it doesn't expand by itself.
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return []
    }
}

public struct RandomizeMacro: MemberMacro, ExtensionMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf decl: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let access = decl.modifierString()
        if let structDecl = decl.as(StructDeclSyntax.self) {
            // Collect stored properties and any @Randomized attribute argument for each.
            var paramLines: [String] = []
            var callLines: [String] = []
            
            for member in structDecl.memberBlock.members {
                guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }
                // Only single-pattern let/var with initializer omitted (stored property)
                guard varDecl.bindings.count == 1, let binding = varDecl.bindings.first else { continue }
                guard binding.accessorBlock == nil else { continue }
                guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
                let name = pattern.identifier.text
                
                // Type annotation required to know how to randomize
                guard let typeAnno = binding.typeAnnotation?.type.trimmedDescription, !typeAnno.isEmpty else { continue }
                
                // Look for @Randomized attribute and capture its `in:` argument (as source text)
                var rangeExpr: String? = nil
                var stringStrategyExpr: String? = nil
                var ignored: Bool = false
                for attr in varDecl.attributes {
                    guard let a = attr.as(AttributeSyntax.self) else { continue }
                    let attrName = a.attributeName.trimmedDescription
                    guard attrName != "Unrandomizable" else {
                        ignored = true
                        continue
                    }
                    guard attrName == "Randomizable" else { continue }
                    if let argList = a.arguments?.as(LabeledExprListSyntax.self) {
                        for le in argList {
                            if let label = le.label?.text, label == "in" {
                                rangeExpr = le.expression.trimmedDescription
                            } else if let label = le.label?.text, label == "strategy" {
                                stringStrategyExpr = le.expression.trimmedDescription
                            }
                        }
                    }
                }
                if !ignored {
                    // Build parameter declaration for the memberwise factory
                    paramLines.append("\(name): \(typeAnno)")
                    
                    // Build call expression for random()
                    let call: String
                    if let rangeExpr {
                        call = "\(typeAnno).random(in: \(rangeExpr))"
                    } else if let stringStrategyExpr {
                        call = "\(stringStrategyExpr).random()"
                    } else {
                        call = "\(typeAnno).random()"
                    }
                    callLines.append("\(name): \(call)")
                }
            }
            
            let argsJoined = callLines.joined(separator: ",\n                ")
            
            let randomFunc: DeclSyntax = """
            #if RANDOMIZING
            \(raw: access) static func random() -> \(structDecl.name) {
                \(structDecl.name)(
                    \(raw: argsJoined)
                )
            }
            #endif
            """
            
            return [randomFunc]
        } else if let enumDecl = decl.as(EnumDeclSyntax.self) {
            var cases: [CaseInfo] = []
            for member in enumDecl.memberBlock.members {
                guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { continue }
                // Check for @Randomized(case: ...) on the case declaration
                var caseProvidedRanges: [String?] = []
                for attr in caseDecl.attributes {
                    guard let a = attr.as(AttributeSyntax.self) else { continue }
                    let attrName = a.attributeName.trimmedDescription
                    guard attrName == "Randomized" else { continue }
                    if let args = a.arguments?.as(LabeledExprListSyntax.self) {
                        for le in args {
                            if let label = le.label?.text, label == "case" {
                                let exprText = le.expression.trimmedDescription
                                // If tuple, split by commas at top-level; otherwise single range
                                if exprText.hasPrefix("(") && exprText.hasSuffix(")") {
                                    let inner = String(exprText.dropFirst().dropLast())
                                    // naive split by comma; sufficient for simple range tuples used in tests
                                    let parts = inner.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                                    caseProvidedRanges = parts.map { part in part.isEmpty ? nil : Optional(part) }
                                } else {
                                    caseProvidedRanges = [exprText]
                                }
                            }
                        }
                    }
                }
                for elem in caseDecl.elements {
                    let caseName = elem.name.text
                    var params: [(String, String?)] = []
                    if let assoc = elem.parameterClause {
                        for param in assoc.parameters {
                            let typeText = param.type.trimmedDescription
                            // Prefer explicit external label if present; otherwise use internal name; if both absent, nil
                            let label: String?
                            if let first = param.firstName?.text, first != "_" {
                                label = first
                            } else if let second = param.secondName?.text, second != "_" {
                                label = second
                            } else {
                                label = nil
                            }
                            params.append((typeText, label))
                        }
                    }
                    // Align caseProvidedRanges count to params count; excess ignored, missing treated as nil
                    var alignedRanges: [String?] = []
                    if !caseProvidedRanges.isEmpty {
                        for i in 0..<params.count {
                            alignedRanges.append(i < caseProvidedRanges.count ? caseProvidedRanges[i] : nil)
                        }
                    }
                    cases.append(CaseInfo(name: caseName, params: params, caseRanges: alignedRanges))
                }
            }
            var caseLines: [String] = []
            for (idx, info) in cases.enumerated() {
                if info.params.isEmpty {
                    if idx == cases.count-1 {
                        caseLines.append("default: return .\(info.name)")
                    } else {
                        caseLines.append("case \(idx): return .\(info.name)")
                    }
                } else {
                    let args = info.params.enumerated().map { (i, param) -> String in
                        let (type, label) = param
                        let range = (i < info.caseRanges.count) ? info.caseRanges[i] : nil
                        let valueExpr: String
                        if let range = range, !range.isEmpty {
                            valueExpr = "\(type).random(in: \(range))"
                        } else {
                            valueExpr = "\(type).random()"
                        }
                        if let label = label, label != "_" {
                            return "\(label): \(valueExpr)"
                        } else {
                            return valueExpr
                        }
                    }.joined(separator: ", ")
                    if idx == cases.count-1 {
                        caseLines.append("default: return .\(info.name)(\(args))")
                    } else {
                        caseLines.append("case \(idx): return .\(info.name)(\(args))")
                    }
                }
            }
            let count = cases.count
            let switchBody = caseLines.joined(separator: "\n                ")
            let randomFunc: DeclSyntax = """
            \(raw: access) static func random() -> \(enumDecl.name) {
                let i = Int.random(in: 0..<\(raw: count))
                switch i {
                \(raw: switchBody)
                }
            }
            """
            return [randomFunc]
        }
        
        return []
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo decl: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Extend structs and enums to conform to Randomizable
        guard decl.as(StructDeclSyntax.self) != nil || decl.as(EnumDeclSyntax.self) != nil else { return [] }
        let extDecl: DeclSyntax = """
            #if RANDOMIZING
            extension \(raw: type.trimmedDescription): Randomizable {}
            #endif
        """
        guard let extensionSyntax = extDecl.as(ExtensionDeclSyntax.self) else { return [] }
        return [extensionSyntax]
    }
}
extension DeclGroupSyntax {
    func modifierString() -> String {
        return modifiers.trimmedDescription
            .replacingOccurrences(of: "final", with: "")
            .replacingOccurrences(of: "indirect", with: "")
    }
}

