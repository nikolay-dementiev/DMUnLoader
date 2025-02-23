//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

public enum DMLoadableType: Hashable, RawRepresentable {
    public typealias RawValue = String
    
    case loading
    case failure(error: Error, onRetry: DMAction? = nil)
    case success(DMLoadableTypeSuccess)
    case none
    
    public var rawValue: RawValue {
        let rawValueForReturn: RawValue
        switch self {
        case .loading:
            rawValueForReturn = "Loading"
        case .failure(let error, _):
            rawValueForReturn = "Error: `\(error)`"
        case .success(let message):
            rawValueForReturn = "Success: `\(message.description)`"
        case .none:
            rawValueForReturn = "None"
        }
        
        return rawValueForReturn
    }
    
    public init?(rawValue: RawValue) {
        nil
    }
    
    public static func == (lhs: DMLoadableType,
                           rhs: DMLoadableType) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
