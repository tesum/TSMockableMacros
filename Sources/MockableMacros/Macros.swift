// The Swift Programming Language
// https://docs.swift.org/swift-book

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
@attached(peer, names: suffixed(Mockable))
public macro Mockable() = #externalMacro(module: "MockableMacrosMacros", type: "MockableMacro")
