//
//  String.swift
//
//
//  Created by Arseny Drozdov on 11.03.2024.
//

import Foundation

extension String {
  var capitalizeFirst: String {
    self.prefix(1).capitalized + dropFirst()
  }
  
  var withoutQuotes: String {
    filter { $0 != "\"" }
  }
}
