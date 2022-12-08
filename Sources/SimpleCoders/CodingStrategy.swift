import Foundation

public protocol DecodingStrategy<Value> {
    
    associatedtype Value
    
    func decode(from decoder: Decoder) throws -> Value
}

public protocol EncodingStrategy<Value> {
    
    associatedtype Value
    
    func encode(_ value: Value, to encoder: Encoder) throws
}

public struct AnyEncodingStrategy<Value>: EncodingStrategy {
    
    private let encoder: (Value, Encoder) throws -> Void
    
    public init(_ encoder: @escaping (Value, Encoder) throws -> Void) {
        self.encoder = encoder
    }
    
    public init(_ strategy: some EncodingStrategy<Value>) {
        self.init(strategy.encode)
    }
    
    public func encode(_ value: Value, to encoder: Encoder) throws {
        try self.encoder(value, encoder)
    }
}

public struct AnyDecodingStrategy<Value>: DecodingStrategy {
    
    private let decoder: (Decoder) throws -> Value
    
    public init(_ decoder: @escaping (Decoder) throws -> Value) {
        self.decoder = decoder
    }
    
    public init(_ strategy: some DecodingStrategy<Value>) {
        self.init(strategy.decode)
    }
    
    public func decode(from decoder: Decoder) throws -> Value {
        try self.decoder(decoder)
    }
}
