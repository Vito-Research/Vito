//
//  ContentView.swift
//  Vito
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
import NiceNotifications
//import TabularData
struct ContentView: View {
    @StateObject var health = Healthv3()
    //@StateObject var ml = ML()
    @State var share = false
    @State var intro = true
    @State var onboarding = UserDefaults.standard.integer(forKey: "onboarding")
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        ZStack {
            Color.clear
                .onAppear() {
                    //health.processData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                        withAnimation(.easeInOut(duration: 2.0)) {
                    intro = false
                        }
                    }
                }
                .onChange(of: scenePhase) { value in
                    withAnimation(.easeOut) {
                    if value == .active {
                    //intro = true
                        
                        #warning("disbled")
                   // health.backgroundDelivery()
                    print("FIRED")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                            withAnimation(.easeInOut(duration: 2.0)) {
                       // intro = false
                            }
                        }
                }
                }
                }
            
        
        if onboarding == 0 {
            OnboardingView(isOnboarding: $onboarding, health: health)
            
        } else {
            if !intro {
        HomeView(health: health)//, ml: ml)
                .transition(.opacity)
               
               
            .onAppear() {
//                do {
//                let df = try DataFrame(contentsOfCSVFile: Bundle.main.url(forResource: "P355472-AppleWatch-hr", withExtension: "csv")!)
//                ml.importCSV(data: df) { data in
//                    health.healthData = data
//                    let risk = health.getRiskScoreAll(bedTime: 6, wakeUpTime: 10, data: data)
//                    //print(risk.1)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//                        let filtered = risk.1.filter {
//                        return $0.risk != 0 && $0.risk != 21
//                    }
//                    //print(health.codableRisk.count)
//                        print(filtered.count)
//                    }
//                }
//                } catch {
                    
                //}
                LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
                }
               
              
//                for type in health.readData {
//                health.getHealthData(type: type, dateDistanceType: .Month, dateDistance: 24) { _ in
//
//                }
                //}
               
            }
            .onChange(of: health.codableRisk) { value in
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(health.codableRisk) {
                    if let json = String(data: encoded, encoding: .utf8) {
                      
                        do {
                            let url = health.getDocumentsDirectory().appendingPathComponent("risk.txt")
                            try json.write(to: url, atomically: false, encoding: String.Encoding.utf8)
                            
                        } catch {
                            print("erorr")
                        }
                    }
                    
                    
                }
//                ml.exportDataToCSV(data: health.healthData) { _ in
//                    share = true
//                }
            }
            .sheet(isPresented: $share) {
               // ShareSheet(activityItems: [ml.getDocumentsDirectory().appendingPathComponent("A.csv")])
                
            }
            }
    }
            if intro && onboarding != 0 {
        IntroView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
