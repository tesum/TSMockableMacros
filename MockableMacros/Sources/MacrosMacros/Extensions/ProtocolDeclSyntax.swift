//
//  ProtocolDeclSyntax.swift
//  
//
//  Created by Arseny Drozdov on 11.03.2024.
//

import SwiftSyntax

extension ProtocolDeclSyntax {
  var typeName: String {
    name.text
  }
  
  var access: String {
    modifiers.first.map { "\($0.trimmedDescription) " } ?? ""
  }
  
  var functions: [FunctionDeclSyntax] {
    memberBlock.members
      .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
  }
  
  var variables: [VariableDeclSyntax] {
    memberBlock.members
      .compactMap { $0.decl.as(VariableDeclSyntax.self) }
  }
}
