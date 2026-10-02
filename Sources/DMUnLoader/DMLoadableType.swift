//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

/// An enumeration representing the possible states of a loadable operation.
/// Conforms to `Hashable` and `RawRepresentable` for easy comparison and serialization.
public enum DMLoadableType: Hashable, RawRepresentable {
    
    public typealias RawValue = String
    
    case loading(provider: AnyDMLoadingViewProvider)
    case failure(error: Error, provider: AnyDMLoadingViewProvider, onRetry: DMAction? = nil)
    case success(DMLoadableTypeSuccess, provider: AnyDMLoadingViewProvider)
    case none
    
    public var rawValue: RawValue {
        let rawValueForReturn: RawValue
        switch self {
        case .loading:
            rawValueForReturn = "Loading"
        case .failure(let error, _, _):
            rawValueForReturn = "Error: `\(error)`"
        case .success(let message, _):
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

extension DMLoadableType {
    /// Whether the state shows a HUD. Every state but `.none` does.
    var showsHUD: Bool {
        if case .none = self {
            return false
        }
        return true
    }
}
