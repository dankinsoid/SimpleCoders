import Foundation

public typealias DateDecodingStrategy = DecodingStrategy<Date>
public typealias DateEncodingStrategy = EncodingStrategy<Date>

// MARK: ISO8601

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public struct ISO8601CodingStrategy: DecodingStrategy, EncodingStrategy {
    
    public var formatter: ISO8601DateFormatter
    
    public init() {
        self.init(formatter: _iso8601Formatter)
    }
    
    public init(formatter: ISO8601DateFormatter) {
        self.formatter = formatter
    }
    
    public func encode(_ value: Date, to encoder: Encoder) throws {
        try formatter.string(from: value).encode(to: encoder)
    }
    
    public func decode(from decoder: Decoder) throws -> Value {
        let string = try String(from: decoder)
        if let result = formatter.date(from: string) {
            return result
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected date string to be ISO8601-formatted."
                )
            )
        }
    }
}

public extension DecodingStrategy where Self == ISO8601CodingStrategy {
    
    static var iso8601: ISO8601CodingStrategy {
        ISO8601CodingStrategy()
    }
}

public extension EncodingStrategy where Self == ISO8601CodingStrategy {
    
    static var iso8601: ISO8601CodingStrategy {
        ISO8601CodingStrategy()
    }
}

// MARK: Deffered to date

public struct DefferedToDateCodingStrategy: DecodingStrategy, EncodingStrategy {
    
    public init() {
    }
    
    public func encode(_ value: Date, to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
    
    public func decode(from decoder: Decoder) throws -> Value {
        try Date(from: decoder)
    }
}

public extension DecodingStrategy where Self == DefferedToDateCodingStrategy {
    
    static var defferedToDate: DefferedToDateCodingStrategy {
        DefferedToDateCodingStrategy()
    }
}

public extension EncodingStrategy where Self == DefferedToDateCodingStrategy {
    
    static var defferedToDate: DefferedToDateCodingStrategy {
        DefferedToDateCodingStrategy()
    }
}

// MARK: Seconds Since 1970

public struct SecondsSince1970CodingStrategy: DecodingStrategy, EncodingStrategy {
    
    public init() {
    }
    
    public func encode(_ value: Date, to encoder: Encoder) throws {
        try value.timeIntervalSince1970.encode(to: encoder)
    }
    
    public func decode(from decoder: Decoder) throws -> Value {
        try Date(timeIntervalSince1970: TimeInterval(from: decoder))
    }
}

public extension DecodingStrategy where Self == SecondsSince1970CodingStrategy {
    
    static var secondsSince1970: SecondsSince1970CodingStrategy {
        SecondsSince1970CodingStrategy()
    }
}

public extension EncodingStrategy where Self == SecondsSince1970CodingStrategy {
    
    static var secondsSince1970: SecondsSince1970CodingStrategy {
        SecondsSince1970CodingStrategy()
    }
}

// MARK: Millieconds Since 1970

public struct MillisecondsSince1970CodingStrategy: DecodingStrategy, EncodingStrategy {
    
    public init() {
    }
    
    public func encode(_ value: Date, to encoder: Encoder) throws {
        try UInt64(value.timeIntervalSince1970 * 1_000).encode(to: encoder)
    }
    
    public func decode(from decoder: Decoder) throws -> Value {
        try Date(timeIntervalSince1970: TimeInterval(from: decoder) / 1_000)
    }
}

public extension DecodingStrategy where Self == MillisecondsSince1970CodingStrategy {
    
    static var millisecondsSince1970: MillisecondsSince1970CodingStrategy {
        MillisecondsSince1970CodingStrategy()
    }
}

public extension EncodingStrategy where Self == MillisecondsSince1970CodingStrategy {
    
    static var millisecondsSince1970: MillisecondsSince1970CodingStrategy {
        MillisecondsSince1970CodingStrategy()
    }
}

// MARK: DateFormatter

public struct DateFormatterCodingStrategy: DecodingStrategy, EncodingStrategy {
    
    public var formatter: DateFormatter
    
    public init(_ formatter: DateFormatter) {
        self.formatter = formatter
    }
    
    public func encode(_ value: Date, to encoder: Encoder) throws {
        try formatter.string(from: value).encode(to: encoder)
    }
    
    public func decode(from decoder: Decoder) throws -> Value {
        let string = try String(from: decoder)
        if let result = formatter.date(from: string) {
            return result
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid date format."
                )
            )
        }
    }
}

public extension DecodingStrategy where Self == DateFormatterCodingStrategy {
    
    static func formatter(_ formatter: DateFormatter) -> DateFormatterCodingStrategy {
        DateFormatterCodingStrategy(formatter)
    }
}

public extension EncodingStrategy where Self == DateFormatterCodingStrategy {
    
    static func formatter(_ formatter: DateFormatter) -> DateFormatterCodingStrategy {
        DateFormatterCodingStrategy(formatter)
    }
}

// MARK: String Formats

public struct StringFormatsDateCodingStrategy: DecodingStrategy, EncodingStrategy {
    
    public var formats: [String]
    public var defaultFormat: String
    private let formatter: DateFormatter
    
    public init(_ defaultFormat: String, _ formats: [String], formatter: DateFormatter) {
        self.formats = formats
        self.defaultFormat = defaultFormat
        self.formatter = formatter
    }
    
    public init(_ defaultFormat: String, _ formats: [String] = []) {
        self.init(defaultFormat, formats, formatter: dateFormatter)
    }
    
    public func encode(_ value: Date, to encoder: Encoder) throws {
        formatter.dateFormat = defaultFormat
        try formatter.string(from: value).encode(to: encoder)
    }
    
    public func decode(from decoder: Decoder) throws -> Value {
        let string = try String(from: decoder)
        for format in [defaultFormat] + formats {
            formatter.dateFormat = format
            if let result = formatter.date(from: string) {
                return result
            }
        }
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Invalid date format."
            )
        )
    }
}

public extension DecodingStrategy where Self == StringFormatsDateCodingStrategy {
    
    static func dateFormats(_ firstFormat: String, _ otherFormats: String...) -> StringFormatsDateCodingStrategy {
        StringFormatsDateCodingStrategy(firstFormat, otherFormats)
    }
}

public extension EncodingStrategy where Self == StringFormatsDateCodingStrategy {
    
    static func dateFormat(_ format: String) -> StringFormatsDateCodingStrategy {
        StringFormatsDateCodingStrategy(format)
    }
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
private let _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = .autoupdatingCurrent
    formatter.locale = .autoupdatingCurrent
    formatter.calendar = .autoupdatingCurrent
    return formatter
}()
