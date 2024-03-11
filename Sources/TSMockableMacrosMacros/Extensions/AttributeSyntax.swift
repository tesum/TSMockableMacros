//
//  AttributeSyntax.swift
//  
//
//  Created by Arseny Drozdov on 11.03.2024.
//

import SwiftSyntax

extension AttributeSyntax {
  var firstArgument: String? {
    if case let .argumentList(list) = arguments {
      return list.first?.expression.description.withoutQuotes
    }
    
    return nil
  }
}
