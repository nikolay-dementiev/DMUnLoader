//
//  ContentView.swift
//  DMErrorHandlingSPMExample
//
//  Created by Nikolay Dementiev on 14.01.2025.
//

import SwiftUI
import DMErrorHandling

struct DMErrorHandlingContentView: View {
    
    @State private var statusText: String = ""
    @State private var showedLoading = false
    
    var body: some View {
//        ZStack {
//            NavigationView {
//                VStack {
//                    
//                    //loading
//                    makeButton(imageName: "Loading Button",
//                               buttonText: "Show Loading screen") {
//                        
//                        showedLoading = true
//                    }
//                    
//                    //Error
//                    makeButton(imageName: "Error Button",
//                               buttonText: "Show Error screen") {
//                        
//                        showedLoading = true
//                    }
//                    
//                    //Success
//                    makeButton(imageName: "Success Button",
//                               buttonText: "Show Success screen") {
//                        
//                        showedLoading = true
//                    }
//                }
//                .padding()
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                    ToolbarItem(placement: .principal) {
//                        HStack {
//                            Image("Various views")
//                                .resizable()
//                                .frame(width: 20, height: 20)
//                            Text("Various screens tester").font(.headline)
//                        }
//                    }
//                }
//            }
//            .safeAreaInset(edge: .bottom) {
//                HStack {
//                    (Text("Current status: ")
//                        .font(.headline) + Text(statusText.isEmpty ? "?" : statusText).font(.body))
//                    .multilineTextAlignment(.center)
//                    .lineLimit(2)
//                }
//            }
//            
////            if showedLoading {
////                LoadableView(type: .loading)
////            }
////            LoadableView(type: .loading)
//            
//
//            
//           Text("dsadfsfsdfsdfsdsdf")
//                .frame(width: 200, height: 300)
//                .background(.yellow)
//        }
//        .frame(width: .infinity,
//                height: .infinity)
        
//        SwiftUIViewTEstView()
        EmptyView()
    }
    
    private func makeButton(imageName: String,
                            buttonText: String,
                            action: @escaping @MainActor () -> Void) -> some View {
        Button (action: action,
                label: {
            Image(imageName)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(.tint)
            Text(buttonText)
                .tint(.black)
        }
        )
        .padding(.init(top: 5,
                       leading: 0,
                       bottom: 5,
                       trailing: 0))
    }
}

#Preview {
    DMErrorHandlingContentView()
}
