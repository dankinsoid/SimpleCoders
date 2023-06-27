import Foundation

public struct IntKey: CodingKey {
    
    public var intValue: Int?
    public var stringValue: String {
        "\(intValue ?? 0)"
    }
    
    public init(intValue: Int) {
        self.intValue = intValue
    }
    
    public init(stringValue: String) {
        intValue = Int(stringValue)
    }
}
