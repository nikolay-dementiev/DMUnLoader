//
//  Inspection.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 14.02.2025.
//
//check  for details: https://github.com/nalexn/ViewInspector/blob/0.10.2/guide.md

@preconcurrency import Combine
import SwiftUI

internal final class Inspection<V>: @unchecked Sendable {

    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()

    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

internal struct InspectionModifier: ViewModifier {
    
    internal let inspection = Inspection<Self>()
    
    internal func body(content: Content) -> some View {
        content
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}
