//
//  MockError.swift
//
//
//  Created by Arseny Drozdov on 11.03.2024.
//

import Foundation

public enum MockError: Error {
  case emptyError
  case error(Error)
}
