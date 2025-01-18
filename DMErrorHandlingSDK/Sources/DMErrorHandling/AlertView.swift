//
//  SwiftUIView.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 17.01.2025.
//

import SwiftUI

public enum AlertViewStatus: RawRepresentable {
    
    public typealias RawValue = AlertViewStatusRawValue
    
    case loadable(Loadable<Any>)
    case unknown
    
    public var rawValue: RawValue {
        let rawValueForReturn: RawValue
        switch self {
        case .unknown:
            rawValueForReturn = .unknown
        case .loadable(.loading):
            rawValueForReturn = .loadaingInProcess
        case .loadable(.success):
            rawValueForReturn = .loadaingSuccessed
        case .loadable(.failure):
            rawValueForReturn = .loadaingFailured
        }
        
        return rawValueForReturn
    }
    
    public init?(rawValue: RawValue) {
        nil
    }
    
    public enum AlertViewStatusRawValue : Sendable {
        case unknown,
             loadaingInProcess,
             loadaingSuccessed,
             loadaingFailured
    }
}

extension AlertViewStatus: Hashable {
    public static func == (lhs: AlertViewStatus,
                           rhs: AlertViewStatus) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}


//TODO: rewrite to use settings from JSON file
/// Kind of Strategy pattern +++
/// for detail: https://github.com/ochococo/Design-Patterns-In-Swift?tab=readme-ov-file#-strategy

/// Uses to provide specific settings for particular status
public protocol AlertViewSettingsForStatus {
    //could be omitted, uses only for confirmation
    var status: AlertViewStatus.RawValue { get }
    //actually settings
    var settings: AlertViewSettingsForStatusValues { get }
}

public protocol AlertViewSettingsForStatusValues: Sendable {
    //    var settings: [AlertViewStatus: AlertViewSettingsForStatus] { get set }
    var messageForegroundColor: Color { get }
}

//Default settings
internal extension AlertViewSettingsForStatusValues {
    var messageForegroundColor: Color { .white }
}

internal struct AlertViewSettingsForStatusUnknown: AlertViewSettingsForStatus {
    
    public let status: AlertViewStatus.RawValue = .unknown
    public let settings: AlertViewSettingsForStatusValues = Settings()
    
    public struct Settings: AlertViewSettingsForStatusValues {
        
    }
}
internal struct AlertViewSettingsForStatusLoadaingInProcess: AlertViewSettingsForStatus {
    
    public let status: AlertViewStatus.RawValue = .loadaingInProcess
    public let settings: AlertViewSettingsForStatusValues = Settings()
    
    public struct Settings: AlertViewSettingsForStatusValues {
        
    }
}
internal struct AlertViewSettingsForStatusLoadaingSuccessed: AlertViewSettingsForStatus {
    
    public let status: AlertViewStatus.RawValue = .loadaingSuccessed
    public let settings: AlertViewSettingsForStatusValues = Settings()
    
    public struct Settings: AlertViewSettingsForStatusValues {
        
    }
}
internal struct AlertViewSettingsForStatusLoadaingFailured: AlertViewSettingsForStatus {
    
    public let status: AlertViewStatus.RawValue = .loadaingFailured
    public let settings: AlertViewSettingsForStatusValues = Settings()
    
    public struct Settings: AlertViewSettingsForStatusValues {
        
    }
}

public protocol AlertViewSettings {
    var settings: [AlertViewStatus.RawValue: AlertViewSettingsForStatus] { get }
}

internal struct AlertViewSettingsData: AlertViewSettings {
    let settings: [AlertViewStatus.RawValue: AlertViewSettingsForStatus] = [
        .unknown : AlertViewSettingsForStatusUnknown(),
        .loadaingInProcess: AlertViewSettingsForStatusLoadaingInProcess(),
        .loadaingSuccessed: AlertViewSettingsForStatusLoadaingSuccessed(),
        .loadaingFailured: AlertViewSettingsForStatusLoadaingFailured(),
    ]
}

// Kind of Strategy pattern ---

protocol VTheme {
    associatedtype VThemeType
    
    func getVTheme() async -> VThemeType
}

public struct AlertView: View, VTheme {
    
    internal let alertViewSettings: AlertViewSettings
    
    private var deviceParameters: DeviceParameters
    
    //     @Binding var shown: Bool
    //     @Binding var closureA: AlertAction?
    //     var isSuccess: Bool
    private(set) var message: String?
    private(set) var status: AlertViewStatus = .unknown
    
    private var deviceScreenSize: CGSize {
        return type(of: deviceParameters).deviceScreenSize
    }
    
    internal init(deviceParameters: DeviceParameters = DMDeviceParameters(),
                  message: String?,
                  status: AlertViewStatus = .unknown,
                  alertViewSettings: AlertViewSettings = AlertViewSettingsData()) {
        
        self.deviceParameters = deviceParameters
        self.message = message
        self.status = status
        self.alertViewSettings = alertViewSettings
    }
    
    public var body: some View {
        VStack {
            //             Color.orange.ignoresSafeArea()
            
            //             let ddd = min(deviceScreenSize.width, deviceScreenSize.height)
            //             Image(isSuccess ? "check":"remove").resizable().frame(width: ddd/9, height: ddd/9).padding(.top, ddd * 10 / 100)
            Spacer()
            VStack {
                if let message {
                    //                Text(message).foregroundColor(Color.white)
                    Text(message).foregroundColor(getVTheme().messageForegroundColor)
                }
            }.frame(minHeight: .zero, maxHeight: .infinity, alignment: .center)
            
            Spacer()
            Divider()
            HStack {
                //TODO: need to adopt that button for various device types (iOS\ watchOS)
                Button("X") {
                    //                     closureA = .cancel
                    //                     shown.toggle()
                }.frame(width: deviceScreenSize.width/2-30, height: 40)
                    .foregroundColor(.white)
                
                Button("Retry") {
                    //                     closureA = .ok
                    //                     shown.toggle()
                }.frame(width: deviceScreenSize.width/2-30, height: 40)
                    .foregroundColor(.white)
            }
            Spacer()
            
        }.frame(width: deviceScreenSize.width-50, height: 200)
        
            .background(Color.black.opacity(0.5))
            .cornerRadius(12)
            .clipped()
        
    }
    
    //TODO: Need to omit force unwrapping
    func getVTheme() -> AlertViewSettingsForStatusValues {
        alertViewSettings.settings[status.rawValue]!.settings
    }
}

#Preview {
    AlertView(message: "Some error message",
              status: .loadable(.failure(error: DMAppError.custom(errorDescription: "Something went wrong error"))))
}
//#Preview {
//    AlertView(message: "Some default message")
//}
