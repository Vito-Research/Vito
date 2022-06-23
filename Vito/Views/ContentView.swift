//
//  ContentView.swift
//  Vito
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
import NiceNotifications
import VitoKit

struct ContentView: View {
    @StateObject var health = Vito(selectedTypes: [.Vitals])
  
    @State var share = false
    @State var intro = true
    @State var onboarding = UserDefaults.standard.integer(forKey: "onboarding")
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        ZStack {
            Color.clear
                .onAppear() {
                   
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                        withAnimation(.beat) {
                    intro = false
                        }
                    }
                }
                .onChange(of: scenePhase) { value in
                    withAnimation(.easeOut) {
                    if value == .active {
//                        for (type, unit) in Array(zip(HKQuantityTypeIdentifier.Vitals, HKUnit.Vitals)) {
                        health.healthData = []
                        for type in HKQuantityTypeIdentifier.Vitals {
                            
                            health.outliers(for: type, unit: type.unit, with: Date().addingTimeInterval(.month * 4), to: Date(), filterToActivity: .active)
                        }
                    print("FIRED")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                            withAnimation(.easeInOut(duration: 2.0)) {
                       
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

                LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
                }
               
               
            }
//            .onChange(of: health.codableRisk) { value in
//
//                let encoder = JSONEncoder()
//                if let encoded = try? encoder.encode(health.codableRisk) {
//                    if let json = String(data: encoded, encoding: .utf8) {
//
//                        do {
//                            let url = health.getDocumentsDirectory().appendingPathComponent("risk.txt")
//                            try json.write(to: url, atomically: false, encoding: String.Encoding.utf8)
//
//                        } catch {
//                            print("erorr")
//                        }
//                    }
//
//
//                }
//            }
            .sheet(isPresented: $share) {
               // ShareSheet(activityItems: [ml.getDocumentsDirectory().appendingPathComponent("A.csv")])
                
            }
            }
    }
            if onboarding != 0  && health.progress < 0.99 {
                IntroView(health: health)
            }
        }  .sheet(isPresented: $health.autheticated, onDismiss: {
            for type in HKQuantityTypeIdentifier.Vitals {
                
                health.outliers(for: type, unit: type.unit, with: Date().addingTimeInterval(.month * 3), to: Date(), filterToActivity: .active)
            }
        }) {
                        DataTypesListView(toggleData: [.Vitals, .Activity, .Mobilty], title: "Health Data", caption: "Abnormally high heart rate while asleep can be a sign of distress from your body, to detect this stress, we collect this data on-device", showBtn: true, vito: health)
                          
                        
                    }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
