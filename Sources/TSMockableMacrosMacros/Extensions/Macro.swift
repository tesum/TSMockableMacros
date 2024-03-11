//
//  Macro.swift
//
//
//  Created by Arseny Drozdov on 11.03.2024.
//

import SwiftSyntax
import SwiftSyntaxMacros

extension Macro {
  static func handleError(_ closure: () throws -> String) throws -> [DeclSyntax] {
    [DeclSyntax(stringLiteral: try closure())]
  }
}
