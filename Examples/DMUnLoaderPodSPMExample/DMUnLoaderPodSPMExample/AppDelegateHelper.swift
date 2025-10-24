//
//  DMUnLoaderPodSPMExample
//
//  Created by Mykola Dementiev
//

import UIKit
import DMUnLoader

struct AppDelegateHelper {
    static private(set) var appDescriprtion: String = ""
    
    static func makeAppDescriprtion() {
#if UIKIT_APP
        appDescriprtion += "\nFramework: `UIKit`"
#elseif SWIFTUI_APP
        appDescriprtion += "\nFramework: `SwiftUI`"
#endif
        
        appDescriprtion += "\nDependency manager: `\(getDependencyManager() ?? "???")`"
    }
    
    static func addAppDescriprtion(_ newString: String) {
        appDescriprtion += newString
    }
    
    static func getDependencyManager() -> String? {
        // Get the path to the .dependency_manager file
        guard let filePath = Bundle.main.path(forResource: ".dependency_manager", ofType: nil) else {
            print("Error: .dependency_manager file not found.")
            return nil
        }
        
        // Read the contents of the file
        do {
            let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
            
            // Parse the DEPENDENCY_MANAGER value
            if let range = fileContents.range(of: "DEPENDENCY_MANAGER=", options: .caseInsensitive) {
                let startIndex = fileContents.index(range.upperBound, offsetBy: 0)
                let remainingString = fileContents[startIndex...]
                
                // Trim whitespace and newlines to extract the value
                let value = remainingString.split(separator: "\n").first?.trimmingCharacters(in: .whitespacesAndNewlines)
                return value
            } else {
                print("Error: DEPENDENCY_MANAGER key not found in .dependency_manager file.")
                return nil
            }
        } catch {
            print("Error reading .dependency_manager file: \(error)")
            return nil
        }
    }
}

extension AppDelegateHelper: DMSceneDelegateHelper {
    static func makeUIKitRootViewHierarhy<LM: DMLoadingManager>(loadingManager: LM) -> UIViewController {
        
        let tabViewController = MainTabViewControllerUIKit(
            loadingManager: loadingManager
        )
        
        return tabViewController
    }
}
