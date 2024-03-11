import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MacrosMacros)
import MacrosMacros

let testMacros: [String: Macro.Type] = [
  "Mockable": MockableMacro.self,
]
#endif

final class MacrosTests: XCTestCase {
  func test_whenAsyncAwait_hasGeneratedBlock() throws {
#if canImport(MacrosMacros)
    assertMacroExpansion(
            """
            @Mockable
            public protocol CarProtocol {
              func runEngine(full: Bool) async throws -> Bool
            }
            """,
    expandedSource:
            """
            public protocol CarProtocol {
              func runEngine(full: Bool) async throws -> Bool
            }
            
            public final class CarProtocolMockable: CarProtocol {
            
              public init() {
              }
            
              // MARK: - Variables
            
            
            
              // MARK: - Functions
            
              // `runEngineFull` mock block
            
              public var runEngineFullCallsCount: Int = 0
              public var runEngineFullCalled: Bool {
                return runEngineFullCallsCount > 0
              }
              public var runEngineFullError: MockError?
              public var runEngineFullResponse: Bool?
            
              public func runEngine(full: Bool) async throws -> Bool {
                runEngineFullCallsCount += 1
                if let error = runEngineFullError {
                    throw error
                }
                return runEngineFullResponse!
              }
            }
            """,
      macros: testMacros
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
  
  func test_whenEmptyClosure_hasGeneratedBlock() throws {
#if canImport(MacrosMacros)
    assertMacroExpansion(
            """
            @Mockable
            public protocol CarProtocol {
              func startEngine(turnOn: Bool, completion: @escaping () -> Void)
            }
            """,
    expandedSource:
            """
            public protocol CarProtocol {
              func startEngine(turnOn: Bool, completion: @escaping () -> Void)
            }
            
            public final class CarProtocolMockable: CarProtocol {
            
              public init() {
              }
            
              // MARK: - Variables
            
            
            
              // MARK: - Functions
            
              // `startEngineTurnOnCompletion` mock block
            
              public var startEngineTurnOnCompletionCallsCount: Int = 0
              public var startEngineTurnOnCompletionCalled: Bool {
                return startEngineTurnOnCompletionCallsCount > 0
              }

              public var startEngineTurnOnCompletionResponse: ((Bool, @escaping () -> Void) -> Void)?

              public func startEngine(turnOn: Bool, completion: @escaping () -> Void) {
                startEngineTurnOnCompletionCallsCount += 1

                startEngineTurnOnCompletionResponse?(turnOn, completion)
              }
            }
            """,
      macros: testMacros
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
  
  func test_whenProtocolHasVariables_BlockIsGenerated() {
#if canImport(MacrosMacros)
    assertMacroExpansion(
            """
            @Mockable
            public protocol CarProtocol {
              var counter: Int { get set }
            }
            """,
    expandedSource:
            """
            public protocol CarProtocol {
              var counter: Int { get set }
            }
            
            public final class CarProtocolMockable: CarProtocol {
            
              public init() {
              }
            
              // MARK: - Variables
            
              public var counter: Int {
                  get {
                      return underlyingCounter
                  }
                  set(value) {
                      underlyingCounter = value
                  }
              }

              public var underlyingCounter: Int!
            
              // MARK: - Functions
            
            
            }
            """,
      macros: testMacros
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}
