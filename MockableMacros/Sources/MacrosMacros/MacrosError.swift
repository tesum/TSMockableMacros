//
//  MacrosError.swift
//
//
//  Created by Arseny Drozdov on 11.03.2024.
//

import Foundation

public enum MacrosError: Error, CustomStringConvertible {
  case onlyProtocol
  
  case variableValidate
  case functionsValidate
  
  public var description: String {
    switch self {
    case .onlyProtocol: return "Can only be applied to protocols."
    case .variableValidate: return "Can't initializate variable."
    case .functionsValidate: return "Function must either have `async throws` effects or an `@escaping` completion handler as the final argument."
    }
  }
}
