<h1 align="center">TSMockableMacros</h1>

<div align="center">
  💻 🤲 🌓 ⚒️
</div>
<div align="center">
  <strong>SPM Package for easily mocking out objects using macros</strong>
</div>
<div align="center">
  It's as simple as adding the @Mockable attribute to your protocol, and then use new class.
</div>

<br />

<h2 align="center">Usage</h2>
<div>
  Just add the attribute to your protocol, as here:
</div>
<br />

```swift
  @Mockable
  public protocol CarProtocol {
    var isStarted: Bool { get set }
  
    func startEngine(full: Bool) async throws -> Bool
    func startEngine(turnOn: Bool, completion: @escaping () -> Void)
    func startEngine(completion: @escaping (Int) -> Void)
    func startEngine(result: Int, completion: @escaping (Result<Int, Never>) -> Void)
  }
```

This will generate the CarProtocolMockable class, which contains variables and functions with additional variables for ease of testing.
<details>
  <summary>Example</summary>

  ```swift
  public final class CarProtocolMockable: CarProtocol {

  public init() {
  }

  // MARK: - Variables

  public var isStarted: Bool {
      get {
          return underlyingIsStarted
      }
      set(value) {
          underlyingIsStarted = value
      }
  }

  public var underlyingIsStarted: Bool!

  // MARK: - Functions

  // `startEngineFull` mock block

  public var startEngineFullCallsCount: Int = 0
  public var startEngineFullCalled: Bool {
    return startEngineFullCallsCount > 0
  }
  public var startEngineFullError: MockError?
  public var startEngineFullResponse: Bool?

  public func startEngine(full: Bool) async throws -> Bool {
    startEngineFullCallsCount += 1
    if let error = startEngineFullError {
        throw error
    }
    return startEngineFullResponse!
  }

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

  // `startEngineCompletion` mock block

    public var startEngineCompletionCallsCount: Int = 0
  public var startEngineCompletionCalled: Bool {
    return startEngineCompletionCallsCount > 0
  }

  public var startEngineCompletionResponse: ((@escaping (Int) -> Void) -> Void)?

  public func startEngine(completion: @escaping (Int) -> Void) {
    startEngineCompletionCallsCount += 1

    startEngineCompletionResponse?(completion)
  }

  // `startEngineResultCompletion` mock block

    public var startEngineResultCompletionCallsCount: Int = 0
  public var startEngineResultCompletionCalled: Bool {
    return startEngineResultCompletionCallsCount > 0
  }

  public var startEngineResultCompletionResponse: ((Int, @escaping (Result<Int, Never>) -> Void) -> Void)?

  public func startEngine(result: Int, completion: @escaping (Result<Int, Never>) -> Void) {
    startEngineResultCompletionCallsCount += 1

    startEngineResultCompletionResponse?(result, completion)
  }
}
  ```
</details>

<h2 align="center">Motivation</h2>

This is an alternative solution for [Sourcery](https://github.com/krzysztofzablocki/Sourcery) AutoMockable. I wanted to create mock classes in different projects, as our product is built using [tuist](https://github.com/tuist/tuist). I ran into the problem that Sourcery could only generate files in one folder, which was unacceptable to me. Therefore, I had to turn to the new features of Swift and study Macros.

<h2 align="center">Alternative</h2>

- [SwiftMocks](https://github.com/frugoman/SwiftMocks)
- [swift-mock](https://github.com/MetalheadSanya/swift-mock)
