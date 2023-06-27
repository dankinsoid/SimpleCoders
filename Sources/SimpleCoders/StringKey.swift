import Foundation

public struct StringKey<Value: LosslessStringConvertible>: CodingKey {
    
    public var stringValue: String { value.description }
    public var intValue: Int? { Int(value.description) }
    public var value: Value
    
    public init?(stringValue: String) {
        guard let value = Value(stringValue) else {
            return nil
        }
        self.value = value
    }
    
    public init?(intValue _: Int) {
        nil
    }
    
    public init(_ value: Value) {
        self.value = value
    }
}
