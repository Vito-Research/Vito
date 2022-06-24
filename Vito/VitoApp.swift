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
import VitoKit
@main
struct VitoApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var share = false

    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

    }
  
}
class AppDelegate: NSObject, UIApplicationDelegate {
    
    let store = HKHealthStore()
    private var useCount = UserDefaults.standard.integer(forKey: "useCount")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.startObservingStepCountChanges()
//        store.enableBackgroundDelivery(for: .quantityType(forIdentifier: .heartRate)!, frequency: .immediate) { ready, err in
//            print(err)
//
//
//        }
        return true
    }
    private func startObservingStepCountChanges() {
        let sampleType =  HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let query: HKObserverQuery = HKObserverQuery(sampleType: sampleType!, predicate: nil, updateHandler: self.stepChangeHandler)
        store.execute(query)
        store.enableBackgroundDelivery(for: sampleType!, frequency: .daily, withCompletion: {(succeeded: Bool, error: Error!) in
            if succeeded{
                print("Enabled background delivery of stepcount changes")
            } else {
                if let theError = error{
                    print("Failed to enable background delivery of stepcount changes. ")
                    print("Error = \(theError)")
                }
            }
        } as (Bool, Error?) -> Void)
    }

    private func stepChangeHandler(query: HKObserverQuery!, completionHandler: HKObserverQueryCompletionHandler!, error: Error!) {

        let vito = Vito(selectedTypes: [.Vitals])
        vito.outliers(for: Outlier(), unit: HKUnit(from: "count/min"), with: Date().addingTimeInterval(.day), to: Date())
        completionHandler()
     }

}
