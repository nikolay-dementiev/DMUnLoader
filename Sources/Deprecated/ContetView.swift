////
////  SwiftUIView.swift
////  DMErrorHandling
////
////  Created by Nikolay Dementiev on 17.01.2025.
////
//
//import SwiftUI
//
//internal struct ContentView: View {
//    
//    @State var shown = false
//    @State var message = ""
////    @State var c: AlertAction?
//    @State var isSuccess = false
//    
//    public var body: some View {
//        
//        ZStack {
////            Color.green.ignoresSafeArea()
//
////            if #available(iOS 16.0, *) {
////                Rectangle().fill(Gradient(colors: [.indigo, .purple]))
////                    .ignoresSafeArea()
////            } else {
////                // Fallback on earlier versions
////            }
//            
//            VStack {
//                Image("demo")
//                    .resizable().frame(width: 300, height: 300)
//                VStack {
//                    Button("Success Alert") {
//                        isSuccess = true
//                        message = "This is the success alert!!"
//                        shown.toggle()
//                    }
//                    
//                    Button("Failure Alert") {
//                        isSuccess = false
//                        message = "This is the failure alert!!"
//                        shown.toggle()
//                        
//                    }
////                    Text(c == .ok ? "ok Clikced" : c == .cancel ? "Cancel Clicked" : "")
//                    Text("Some Clicked")
//                    
//                }
//                Spacer()
//            }.blur(radius: shown ? 30 : 0)
//            
//            if shown {
//                AlertView(/*shown: $shown, closureA: $c, isSuccess: isSuccess, */ message: message)
//            }
//            
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
