////
////  File.swift
////  DMErrorHandling
////
////  Created by Nikolay Dementiev on 25.01.2025.
////
//
//import Foundation
//
//public final class ThreadExecutor {
//    
//    static public func performOnMainThread(_ block: () -> Void) {
//        if Thread.isMainThread {
//            block()
//            return
//        } else {
//            DispatchQueue.main.sync {
//                block()
//                return
//            }
//        }
//    }
//}
