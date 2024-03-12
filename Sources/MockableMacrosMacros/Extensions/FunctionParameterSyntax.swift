//
//  FunctionParameterSyntax.swift
//
//
//  Created by Arseny Drozdov on 11.03.2024.
//

import SwiftSyntax

extension FunctionParameterSyntax {
  var variableName: String {
    (secondName ?? firstName).text
  }
  
  var typeString: String {
    trimmed.type.description
  }
}
