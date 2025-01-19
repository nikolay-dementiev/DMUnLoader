//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 19.01.2025.
//

import SwiftUI

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
