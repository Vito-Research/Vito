//
//  VitoApp.swift
//  Vito
//
//  Created by Andreas on 9/7/21.
//

import SwiftUI
import TabularData
import HealthKit
import FirebaseCore
@main
struct VitoApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var share = false

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

    }
  
}
class AppDelegate: UIResponder, UIApplicationDelegate {
    
  
    private var useCount = UserDefaults.standard.integer(forKey: "useCount")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

}
