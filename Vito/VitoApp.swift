//
//  VitoApp.swift
//  Vito
//
//  Created by Andreas on 9/7/21.
//

import SwiftUI
import TabularData
import HealthKit
@main
struct VitoApp: App {
   // @StateObject var health = Healthv3()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var health = Health()
    @StateObject var healthv3 = Healthv3()
    @State var share = false
    var body: some Scene {
        WindowGroup {
            ContentView()
               
//            EmptyView()
//                .sheet(isPresented: $share) {
//                    if #available(iOS 15, *) {
//                        ShareSheet(activityItems: [ML().getDocumentsDirectory().appendingPathComponent("Vito_Health_Data.csv"), ML().getDocumentsDirectory().appendingPathComponent("Vito_Risk_Data.csv")])
//                    } else {
//                        // Fallback on earlier versions
//                    }
//
//                }
//                .onAppear() {
//                    if let filepath = Bundle.main.path(forResource: "Orig_NonFitbit_HR2", ofType: "csv") {
//                        do {
//
//                            health.healthData  = []
//                            if #available(iOS 15, *) {
//                                ML().importCSV(data: try DataFrame(contentsOfCSVFile: URL(fileURLWithPath: filepath))) { healthData in
//                                    health.healthData = healthData
//
//                                    let earlyDate = health.healthData.map{$0.date}.min()
//                                    let laterDate = health.healthData.map{$0.date}.max()
//                                    if let earlyDate = earlyDate {
//                                        if let laterDate = laterDate {
//                                    health.codableRisk = []
//
//                                   // for date in Date.dates(from: earlyDate, to: laterDate) {
//
//
//
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                                            healthv3.getAvgPerNight(healthData.filter{!$0.data.isNaN})
//                                            let riskArr = healthv3.getRiskScore(healthData, avgs: healthv3.healthData)
//
//                                            if #available(iOS 15, *) {
//                                                ML().exportDataToCSV(data: riskArr, codableRisk: health.codableRisk) { _ in
//                                                    share = true
//                                                }
//                                            } else {
//                                                // Fallback on earlier versions
//                                            }
////                                            for riskIndex in riskArr.indices {
////                                                health.healthData[riskIndex].risk = riskArr[riskIndex]
////                                            }
//                                        }
//                                        }
//
//                                    //}
//
//                                    }
//
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//
//                                    }
//                                }
//                            } else {
//                                // Fallback on earlier versions
//                            }
//
//                        } catch {
//                            // contents could not be loaded
//                        }
//                    } else {
//                        // example.txt not found!
//                        print("OOOOoof")
//                    }
//
//
//
////                    let earlyDate = Calendar.current.date(
////                      byAdding: .month,
////                      value: -3,
////                      to: Date()) ?? Date()
////                    health.codableRisk = []
////                    for date in Date.dates(from: earlyDate, to: Date()) {
////                   let risk = health.getRiskScorev2(date: date)
////                        //health.codableRisk.append(CodableRisk(id: risk.id, date: date, risk: risk.risk, explanation: []))
////                    }
////
//
//                }
        }
    }
  
}
class AppDelegate: UIResponder, UIApplicationDelegate {
    
  
    private var useCount = UserDefaults.standard.integer(forKey: "useCount")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      //  backgroundDelivery()
        return true
    }

}
