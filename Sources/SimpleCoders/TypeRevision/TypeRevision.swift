import Foundation

public struct TypeRevision {

    public let customDescription: (Any.Type, Any?) -> CodableContainerValue?

    public init(custom: @escaping (Any.Type, Any?) -> CodableContainerValue?) {
		customDescription = custom
	}

    public init() {
		self.init { _, _ in nil }
	}

    public func describeType(of value: Encodable) throws -> TypeInfo {
		let encoder = TypeRevisionEncoder(context: self)
		try encoder.encode(value, type: type(of: value))
		return encoder.result
	}

    public func describe(type: Decodable.Type) throws -> TypeInfo {
		let decoder = TypeRevisionDecoder(context: self)
		try decoder.decode(type)
		return decoder.result
	}
}
