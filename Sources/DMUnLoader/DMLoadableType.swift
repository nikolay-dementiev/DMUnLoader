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
    case failure(error: any Error, provider: AnyDMLoadingViewProvider, onRetry: (any DMAction)? = nil)
    case success(any DMLoadableTypeSuccess, provider: AnyDMLoadingViewProvider)
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
    
    /// Two states are equal when they are the same case and show the same thing:
    /// - the same view provider: the provider given to the manager. Erasing one provider
    ///   twice gives equal states; two provider instances give different states.
    /// - for a success, a payload of the same type with the same `description`;
    /// - for a failure, an error of the same type with the same description, and the same
    ///   retry action: both `nil`, or the same `id`. A failure with a retry action and one
    ///   without are different states.
    public static func == (lhs: DMLoadableType,
                           rhs: DMLoadableType) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.loading(lhsProvider), .loading(rhsProvider)):
            return lhsProvider.wrappedProviderID == rhsProvider.wrappedProviderID
        case let (.success(lhsPayload, lhsProvider), .success(rhsPayload, rhsProvider)):
            return lhsProvider.wrappedProviderID == rhsProvider.wrappedProviderID
                && DescribedValue(lhsPayload) == DescribedValue(rhsPayload)
        case let (.failure(lhsError, lhsProvider, lhsRetry), .failure(rhsError, rhsProvider, rhsRetry)):
            return lhsProvider.wrappedProviderID == rhsProvider.wrappedProviderID
                && DescribedValue(lhsError) == DescribedValue(rhsError)
                && lhsRetry?.id == rhsRetry?.id
        case (.none, _), (.loading, _), (.success, _), (.failure, _):
            return false
        }
    }

    /// Hashes what `==` compares.
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .none:
            hasher.combine(0)
        case let .loading(provider):
            hasher.combine(1)
            hasher.combine(provider.wrappedProviderID)
        case let .success(payload, provider):
            hasher.combine(2)
            hasher.combine(provider.wrappedProviderID)
            hasher.combine(DescribedValue(payload))
        case let .failure(error, provider, onRetry):
            hasher.combine(3)
            hasher.combine(provider.wrappedProviderID)
            hasher.combine(DescribedValue(error))
            hasher.combine(onRetry?.id)
        }
    }
}

/// A value with no equality of its own, compared by its dynamic type and its description.
struct DescribedValue: Hashable {
    private let type: ObjectIdentifier
    private let description: String

    init(_ value: Any) {
        self.type = ObjectIdentifier(Swift.type(of: value))
        self.description = String(describing: value)
    }
}

extension DMLoadableType {
    /// The phase of the state: what the policies of the HUD decide on.
    package var phase: HUDPhase {
        switch self {
        case .none:
            return .none
        case .loading:
            return .loading
        case .success:
            return .success
        case let .failure(_, _, onRetry):
            return onRetry == nil ? .failure : .failureWithRetry
        }
    }

    /// Whether the state shows a HUD. Every state but `.none` does.
    package var showsHUD: Bool {
        phase.showsHUD
    }
}
