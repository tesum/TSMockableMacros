//
//  Plugin.swift
//  
//
//  Created by Arseny Drozdov on 11.03.2024.
//

#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    MockableMacro.self,
  ]
}
#endif
