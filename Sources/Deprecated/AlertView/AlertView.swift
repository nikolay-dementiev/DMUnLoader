////
////  SwiftUIView.swift
////  DMErrorHandling
////
////  Created by Nikolay Dementiev on 17.01.2025.
////
//
//import SwiftUI
//
//public struct AlertView: View, VTheme {
//    
//    internal let alertViewSettings: AlertViewSettings
//    
//    //     @Binding var shown: Bool
//    //     @Binding var closureA: AlertAction?
//    //     var isSuccess: Bool
//    private(set) var message: String?
//    private(set) var status: AlertViewStatus = .unknown
//    
//    internal init(message: String?,
//                  status: AlertViewStatus = .unknown,
//                  alertViewSettings: AlertViewSettings = AlertViewSettingsData()) {
//        
//        self.message = message
//        self.status = status
//        self.alertViewSettings = alertViewSettings
//    }
//    
//    public var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .center) {
//                VStack {
//                    //             Color.orange.ignoresSafeArea()
//                    
//                    //             let ddd = min(deviceScreenSize.width, deviceScreenSize.height)
//                    //             Image(isSuccess ? "check":"remove").resizable().frame(width: ddd/9, height: ddd/9).padding(.top, ddd * 10 / 100)
//                    Spacer()
//                    VStack {
//                        if let message {
//                            //                Text(message).foregroundColor(Color.white)
//                            Text(message).foregroundColor(getVTheme().messageForegroundColor)
//                        }
//                    }.frame(minHeight: .zero, maxHeight: .infinity, alignment: .center)
//                    
//                    Spacer()
//                    Divider()
//                    HStack {
//                        //TODO: need to adopt that button for various device types (iOS\ watchOS)
//                        Button("X") {
//                            //                     closureA = .cancel
//                            //                     shown.toggle()
//                        }.frame(width: geometry.size.width/2-30, height: 40)
//                            .foregroundColor(.white)
//                        
//                        Button("Retry") {
//                            //                     closureA = .ok
//                            //                     shown.toggle()
//                        }.frame(width: geometry.size.width/2-30, height: 40)
//                            .foregroundColor(.white)
//                    }
//                    Spacer()
//                    
//                }.frame(width: geometry.size.width-50, height: 200)
//                
//                    .background(Color.black.opacity(0.5))
//                    .cornerRadius(12)
//                    .clipped()
//            }
//            .frame(maxWidth: .infinity,
//                   maxHeight: .infinity)
//        }
//    }
//    
//    //TODO: Need to omit force unwrapping
//    func getVTheme() -> AlertViewSettingsForStatusValues {
//        alertViewSettings.settings[status.rawValue]!.settings
//    }
//}
//
//fileprivate protocol VTheme {
//    associatedtype VThemeType
//    
//    func getVTheme() async -> VThemeType
//}
//
//#Preview {
////    AlertView(message: "Some error message",
////              status: .loadable(.failure(error: DMAppError.custom(errorDescription: "Something went wrong error"))))
//    AlertView(message: "Some loading message",
//              status: .loadable(.loading))
//}
////#Preview {
////    AlertView(message: "Some default message")
////}
