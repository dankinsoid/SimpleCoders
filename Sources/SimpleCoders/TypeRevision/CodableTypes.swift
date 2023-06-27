import Foundation

public struct TypeInfo {

    public static let any = TypeInfo(type: Any.self, container: .single(.null))

    public var type: Any.Type
    public var isOptional = false
    public var container: CodableContainerValue
    
    public init(type: Any.Type, isOptional: Bool = false, container: CodableContainerValue) {
        self.type = type
        self.isOptional = isOptional
        self.container = container
    }
}

public struct KeyedInfo {

    public var fields: OrderedDictionary<String, TypeInfo> = [:]
    public var isFixed = true

    public subscript(_ key: String) -> TypeInfo {
		get { fields[key] ?? .any }
		set { fields[key] = newValue }
	}
    
    public init(fields: OrderedDictionary<String, TypeInfo> = [:], isFixed: Bool = true) {
        self.fields = fields
        self.isFixed = isFixed
    }
}

public indirect enum CodableContainerValue {

	case single(CodableValues)
	case keyed(KeyedInfo)
	case unkeyed(TypeInfo)
	case recursive

    public var keyed: KeyedInfo {
		get {
			if case let .keyed(info) = self {
				return info
			}
			return KeyedInfo()
		}
		set {
			self = .keyed(newValue)
		}
	}

    public var unkeyed: TypeInfo? {
		get {
			if case let .unkeyed(value) = self {
				return value
			}
			return nil
		}
		set {
			if let newValue {
				self = .unkeyed(newValue)
			}
		}
	}

    public var single: CodableValues? {
		get {
			if case let .single(value) = self {
				return value
			}
			return nil
		}
		set {
			if let newValue {
				self = .single(newValue)
			}
		}
	}
}

public enum CodableValues: Equatable {

	case int(Int?)
	case int8(Int8?)
	case int16(Int16?)
	case int32(Int32?)
	case int64(Int64?)
	case uint(UInt?)
	case uint8(UInt8?)
	case uint16(UInt16?)
	case uint32(UInt32?)
	case uint64(UInt64?)
	case double(Double?)
	case float(Float?)
	case bool(Bool?)
	case string(String?)
	case null

    public var type: Any.Type {
		switch self {
		case .int: return Int.self
		case .int8: return Int8.self
		case .int16: return Int16.self
		case .int32: return Int32.self
		case .int64: return Int64.self
		case .uint: return UInt.self
		case .uint8: return UInt8.self
		case .uint16: return UInt16.self
		case .uint32: return UInt32.self
		case .uint64: return UInt64.self
		case .double: return Double.self
		case .float: return Float.self
		case .bool: return Bool.self
		case .string: return String.self
		case .null: return Any.self
		}
	}
}
