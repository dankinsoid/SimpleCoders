import Foundation

public protocol KeyDecodingStrategy {
    
    func decode(currentKey: CodingKey, codingPath: [CodingKey]) throws -> String
}

public extension KeyDecodingStrategy {
    
    func decode(from key: String) throws -> String {
        try decode(currentKey: PlainCodingKey(key), codingPath: [])
    }
}

public protocol KeyEncodingStrategy {
    
    func encode(currentKey: CodingKey, codingPath: [CodingKey]) throws -> String
}

public extension KeyEncodingStrategy {
    
    func encode(from key: String) throws -> String {
        try encode(currentKey: PlainCodingKey(key), codingPath: [])
    }
}


// MARK: Use Deafult Key

public struct UseDeafultKeyCodingStrategy: KeyDecodingStrategy, KeyEncodingStrategy {
    
    public init() {
    }
    
    public func decode(currentKey: CodingKey, codingPath: [CodingKey]) throws -> String {
        currentKey.stringValue
    }
    
    public func encode(currentKey: CodingKey, codingPath: [CodingKey]) throws -> String {
        currentKey.stringValue
    }
}

public extension KeyDecodingStrategy {
    
    static var useDefaultKeys: UseDeafultKeyCodingStrategy {
        UseDeafultKeyCodingStrategy()
    }
}

public extension KeyEncodingStrategy {
    
    static var useDefaultKeys: UseDeafultKeyCodingStrategy {
        UseDeafultKeyCodingStrategy()
    }
}

public extension KeyEncodingStrategy where Self: KeyDecodingStrategy {
    
    static var useDefaultKeys: UseDeafultKeyCodingStrategy {
        UseDeafultKeyCodingStrategy()
    }
}

// MARK: From/To snake case

public struct SnakeCasesCodingKeyStrategy: KeyDecodingStrategy, KeyEncodingStrategy {
    
    public var decodeSeparators: CharacterSet
    public var encodeSeparator: String
    
    public init(decodeSeparators: CharacterSet, encodeSeparator: String) {
        self.decodeSeparators = decodeSeparators
        self.encodeSeparator = encodeSeparator
    }
    
    public init(separator: CharacterSet.Element = "_") {
        self.init(decodeSeparators: [separator], encodeSeparator: String(separator))
    }
    
    public func decode(currentKey: CodingKey, codingPath: [CodingKey]) throws -> String {
        let stringKey = currentKey.stringValue
        guard !stringKey.isEmpty else { return stringKey }
        var result = ""
        var needUppercase = false
        var i = 0
        let endIndex = stringKey.count - 1
        for char in stringKey {
            if decodeSeparators.contains(char), i > 0, i < endIndex {
                needUppercase = true
            } else if needUppercase {
                result += String(char).uppercased()
                needUppercase = false
            } else {
                result.append(char)
            }
            i += 1
        }
        return result
    }
    
    public func encode(currentKey: CodingKey, codingPath: [CodingKey]) throws -> String {
        let stringKey = currentKey.stringValue
        guard !stringKey.isEmpty else { return stringKey }
        
        var words : [Range<String.Index>] = []
        // The general idea of this algorithm is to split words on transition from lower to upper case, then on transition of >1 upper case characters to lowercase
        //
        // myProperty -> my_property
        // myURLProperty -> my_url_property
        //
        // We assume, per Swift naming conventions, that the first character of the key is lowercase.
        
        var wordStart = stringKey.startIndex
        var searchRange = stringKey.index(after: wordStart)..<stringKey.endIndex
        
        // Find next uppercase character
        while let upperCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.uppercaseLetters, options: [], range: searchRange) {
            let untilUpperCase = wordStart..<upperCaseRange.lowerBound
            words.append(untilUpperCase)
            
            // Find next lowercase character
            searchRange = upperCaseRange.lowerBound..<searchRange.upperBound
            guard let lowerCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.lowercaseLetters, options: [], range: searchRange) else {
                // There are no more lower case letters. Just end here.
                wordStart = searchRange.lowerBound
                break
            }
            
            // Is the next lowercase letter more than 1 after the uppercase? If so, we encountered a group of uppercase letters that we should treat as its own word
            let nextCharacterAfterCapital = stringKey.index(after: upperCaseRange.lowerBound)
            if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
                // The next character after capital is a lower case character and therefore not a word boundary.
                // Continue searching for the next upper case for the boundary.
                wordStart = upperCaseRange.lowerBound
            } else {
                // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before the lower case character.
                let beforeLowerIndex = stringKey.index(before: lowerCaseRange.lowerBound)
                words.append(upperCaseRange.lowerBound..<beforeLowerIndex)
                
                // Next word starts at the capital before the lowercase we just found
                wordStart = beforeLowerIndex
            }
            searchRange = lowerCaseRange.upperBound..<searchRange.upperBound
        }
        words.append(wordStart..<searchRange.upperBound)
        let result = words
            .map { range in
                stringKey[range].lowercased()
            }
            .joined(separator: encodeSeparator)
        return result
    }
}

public extension KeyDecodingStrategy {
    
    static func convertFromSnakeCase(separators: CharacterSet = CharacterSet(charactersIn: "_")) -> SnakeCasesCodingKeyStrategy {
        SnakeCasesCodingKeyStrategy(decodeSeparators: separators, encodeSeparator: "_")
    }
}

public extension KeyEncodingStrategy {
    
    static func convertToSnakeCase(separator: String = "_") -> SnakeCasesCodingKeyStrategy {
        SnakeCasesCodingKeyStrategy(decodeSeparators: CharacterSet(charactersIn: separator), encodeSeparator: separator)
    }
}

extension CharacterSet {
    
    func contains(_ character: Character) -> Bool {
        for scalar in character.unicodeScalars {
            if !contains(scalar) { return false }
        }
        return true
    }
    
}
