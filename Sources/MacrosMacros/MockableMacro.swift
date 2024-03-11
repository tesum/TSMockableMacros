//
//  MockableMacro.swift
//
//
//  Created by Arseny Drozdov on 11.03.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// A macro that creates a new mock class based on the protocol.
///
/// For example:
///
///      @Mockable
///      protocol CarProtocol {
///       func startEngine() async throws -> Bool
///      }
///
/// - Note: Can use with `async/await`, `completion` functions, also any variables.
public struct MockableMacro: PeerMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    try handleError {
      guard let type = declaration.as(ProtocolDeclSyntax.self) else {
        throw MacrosError.onlyProtocol
      }
      
      let name = node.firstArgument ?? "\(type.typeName)\(node.attributeName)"
      return try type.createMock(named: name)
    }
  }
}

fileprivate extension ProtocolDeclSyntax {
  func createMock(named mockName: String) throws -> String {
    """
    \(access)final class \(mockName): \(typeName) {
      
      \(access)init() { }
    
      // MARK: - Variables
    
      \(try implementVariables())
    
      // MARK: - Functions
    
      \(try implementFunctions())
    }
    """
  }
  
  func implementVariables() throws -> String {
    try self.variables
      .flatMap { try [$0.mockVariablesImplementation(access: access)] }
      .joined(separator: "\n\n")
  }
  
  func implementFunctions() throws -> String {
    try self.functions
      .flatMap { try [$0.mockFunctionsImplementation(access: access)] }
      .joined(separator: "\n\n")
  }
}

fileprivate extension VariableDeclSyntax {
  func mockVariablesImplementation(access: String) throws -> String {
    guard
      let variable = bindings.first,
      let pattern = variable.pattern.as(IdentifierPatternSyntax.self),
      let typeAnnotation = variable.typeAnnotation?.type.as(IdentifierTypeSyntax.self)
    else {
      throw MacrosError.variableValidate
    }
    
    let name = pattern.identifier.text
    let underlyingName = "underlying\(name.capitalizeFirst)"
    return """
    \(access)\(bindingSpecifier.text) \(name): \(typeAnnotation.name.text) {
    get { return \(underlyingName) }
    set(value) { \(underlyingName) = value }
    }
    
    public var \(underlyingName): \(typeAnnotation.name.text)!
    """
  }
}

fileprivate extension FunctionDeclSyntax {
  func mockFunctionsImplementation(access: String) throws -> String {
    try self.validateSignature()
    
    if hasEscapingCompletion, callbackName == nil {
      throw MacrosError.functionsValidate
    }
    
    let argumentsMocked = parameters.map(\.variableName).joined(separator: ", ")
    let returnType: String =
    switch style {
    case .concurrency:
      "return \(functionName)\(parameterInlineString)Response!"
    case .completionHandler:
      "\(functionName)\(parameterInlineString)Response?(\(argumentsMocked))"
    }
    
    return """
        // `\(functionNameString)` mock block
        
          \(access)var \(functionNameString)CallsCount: Int = 0
          \(access)var \(functionNameString)Called: Bool {
            return \(functionNameString)CallsCount > 0
          }
          \(hasThrows ? "\(access)var \(functionNameString)Error: MockError?": "")
          \(access)var \(functionNameString)Response: \(mockClosureType)
          
          \(access)func \(functionName)\(signature) {
            \(functionNameString)CallsCount += 1
            \(addThrowsHandler())
            \(returnType)
          }
        """
  }

  private func addThrowsHandler() -> String {
    guard hasThrows else { return "" }
    return """
      if let error = \(functionNameString)Error {
      throw error
      }
      """
  }
  
  private var mockClosureType: String {
    let parameterTypes = parameters.map(\.typeString).joined(separator: ", ")
    let returnType = signature.returnClause?.type.trimmedDescription ?? "Void"
    
    if style == .completionHandler {
      let effects = effects.isEmpty ? "" : " \(effects.joined(separator: " "))"
      return "((\(parameterTypes))\(effects) -> \(returnType))?"
    } else {
      return "\(returnType)?"
    }
  }
  
  private var functionNameString: String {
    "\(functionName)\(parameterInlineString)"
  }
}
