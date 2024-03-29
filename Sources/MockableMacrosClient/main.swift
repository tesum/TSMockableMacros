import MockableMacros

//@Mockable
class Car {
  
}

@Mockable
public protocol CarProtocol {
  var isStarted: Bool { get set }
  
  func startEngine(full: Bool) async throws -> Bool
  func startEngine(turnOn: Bool, completion: @escaping () -> Void)
  func startEngine(completion: @escaping (Int) -> Void)
  func startEngine(result: Int, completion: @escaping (Result<Int, Never>) -> Void)
}
