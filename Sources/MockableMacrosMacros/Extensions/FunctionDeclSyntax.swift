//
//  FunctionDeclSyntax.swift
//
//
//  Created by Arseny Drozdov on 11.03.2024.
//

import Foundation
import SwiftSyntax

extension FunctionDeclSyntax {
  enum ReturnType: Equatable {
    struct TupleParameter: Equatable {
      let label: String?
      let type: String
    }
    
    case tuple([TupleParameter])
    case type(String)
  }
  
  enum AsyncStyle {
    case concurrency
    case completionHandler
  }
  
  // MARK: Async Style
  
  var style: AsyncStyle {
    hasEscapingCompletion ? .completionHandler : .concurrency
  }
  
  var hasThrows: Bool {
    effects.contains("throws")
  }
  
  func validateSignature() throws {
    let hasAsyncAwait = effects.contains("async") && hasThrows
    guard hasEscapingCompletion || hasAsyncAwait else {
      throw MacrosError.functionsValidate
    }
  }
  
  var hasEscapingCompletion: Bool {
    guard let parameter = parameters.last, returnType == nil else {
      return false
    }
    
    let type = parameter.type.trimmedDescription
    let isCompletion = type.hasPrefix("@escaping (")
    return isCompletion
  }
  
  // MARK: Function effects & attributes
  
  var functionName: String {
    name.text
  }
  
  var effects: [String] {
    [signature.effectSpecifiers?.asyncSpecifier, signature.effectSpecifiers?.throwsSpecifier]
      .compactMap { $0 }
      .map { $0.text }
  }
  
  var parameters: [FunctionParameterSyntax] {
    signature
      .parameterClause
      .parameters
      .compactMap { $0.as(FunctionParameterSyntax.self) }
  }
  
  var parameterInlineString: String {
    parameters
      .map(\.variableName.capitalizeFirst)
      .joined()
  }
  
  // MARK: Parameter Information
  
  var callbackName: String? {
    guard let parameter = parameters.last, style == .completionHandler else {
      return nil
    }
    
    return parameter.variableName
  }
  
  private var callbackType: String? {
    guard let parameter = parameters.last, returnType == nil else {
      return nil
    }
    
    let type = parameter.type.trimmedDescription
    if type == "@escaping (Response) -> Void" {
      return "Response"
    } else {
      return type
        .replacingOccurrences(of: "@escaping (Result<", with: "")
        .replacingOccurrences(of: ", Error>) -> Void", with: "")
    }
  }
  
  // MARK: Return Data
  
  var returnResponseOnly: Bool {
    responseType == .type("Response")
  }
  
  var responseType: ReturnType? {
    if style == .completionHandler, let callbackType {
      return .type(callbackType)
    }
    
    return returnType
  }
  
  private var returnType: ReturnType? {
    guard let type = signature.returnClause?.type else {
      return nil
    }
    
    if let type = type.as(TupleTypeSyntax.self) {
      return .tuple(type.elements.map { .init(label: $0.firstName?.text, type: $0.type.trimmedDescription) })
    } else {
      return .type(type.trimmedDescription)
    }
  }
}
