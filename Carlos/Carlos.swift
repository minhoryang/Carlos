import Foundation

internal struct CarlosGlobals {
  static let QueueNamePrefix = "com.carlos."
  static let Caches = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] 
}

internal func wrapClosureIntoCacheLevel<A, B>(closure: (key: A) -> Result<B>) -> BasicCache<A, B> {
  return BasicCache(
    getClosure: closure,
    setClosure: { (_, _) in },
    clearClosure: { },
    memoryClosure: { }
  )
}

internal func wrapClosureIntoFetcher<A, B>(closure: (key: A) -> Result<B>) -> BasicFetcher<A, B> {
  return BasicFetcher(getClosure: closure)
}

internal func wrapClosureIntoOneWayTransformer<A, B>(transformerClosure: A -> Result<B>) -> OneWayTransformationBox<A, B> {
  return OneWayTransformationBox(transform: transformerClosure)
}

infix operator =>> { associativity left }

/// An abstraction for a generic cache level
public protocol CacheLevel {
  /// A typealias for the key the cache level accepts
  typealias KeyType
  
  /// A typealias for the data the cache returns in the success closure
  typealias OutputType
  
  /**
  Tries to get a value from the cache level
  
  - parameter key: The key of the value you would like to get
  
  - returns: a Result that you can attach success and failure closures to
  */
  func get(key: KeyType) -> Result<OutputType>
  
  /**
  Tries to set a value on the cache level
  
  - parameter value: The bytes to set on the cache level
  - parameter key: The key of the value you're trying to set
  */
  func set(value: OutputType, forKey key: KeyType)
  
  /**
  Asks to clear the cache level
  */
  func clear()
  
  /**
  Notifies the cache level that a memory warning was thrown, and asks it to do its best to clean some memory
  */
  func onMemoryWarning()
}

/// An abstraction for a generic cache level that can only fetch values but not store them
public protocol Fetcher: CacheLevel {}

/// Extending the Fetcher protocol to have a default no-op implementation for clear, onMemoryWarning and set
extension Fetcher {
  /// No-op
  public func clear() {}
  
  /// No-op
  public func onMemoryWarning() {}
  
  /// No-op
  public func set(value: OutputType, forKey key: KeyType) {}
}