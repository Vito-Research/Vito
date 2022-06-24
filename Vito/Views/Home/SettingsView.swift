//
//  SettingsView.swift
//  Vito
//
//  Created by Andreas Ink on 6/23/22.
//

import SwiftUI
import VitoKit
import SFSafeSymbols
import HealthKit

struct SettingsView: View {
    @ObservedObject var health: Vito
    @State var details = false
    @State var onboarding = false
    @State var share = false
    @State var isOnboarding = 0
    
    @StateObject var fire = FirebaseManager()
    var body: some View {
        Form {
            Section {
//                Toggle(isOn: $health.settings.share) {
//                    Text("Share On-Device Health Data")
//                } .onChange(of: health.settings.share) { new in
//                    if new {
//                        health.auth(selectedTypes: [.Vitals])
//                    }
//                }
                Toggle(isOn: $health.settings.backgroundMode) {
                    Text("Background Health Data")
                }
                Toggle(isOn: $health.settings.notifications) {
                    Text("Notifications")
                }
            } header: {
                HStack {
                Text("Privacy")
                    Spacer()
                    Button {
                        details = true
                    } label: {
                        Image(systemSymbol: .questionmark)
                    }

                }
            }
           
            
            Section("Export Data") {
                VStack(alignment: .leading) {
#if targetEnvironment(simulator)

#else
      
                Button {
              ML().exportAsCSV(health.healthData)

                } label: {
                    Text("Download Spreadsheet")
                }

                .sheet(isPresented: $share) {
                    ShareSheet(activityItems: [ML().getDocumentsDirectory().appendingPathComponent("HealthData.csv")])
                }
#endif
                Text("Exports your health data to a csv file")
                    .font(.custom("Poppins", size: 12))
                    .opacity(0.6)
                    .padding(.top, 3)
                }
                VStack(alignment: .leading) {
                Button {
                   
                    
                     fire.saveDataToFirebase(HealthQuery(health: health.healthData))
                    
                } label: {
                    Text("Export Data to Vito")
                }
                Text("Exports your health data off-device to improve the app")
                    .font(.custom("Poppins", size: 12))
                    .opacity(0.6)
                    .padding(.top, 3)
                }
            }
            Section("About") {
                Link(destination: URL(string: "https://vitovitals.org")!) {
                    Text("Vito's Website")
                }
                Button("Onboarding") {
                    onboarding = true
                } .sheet(isPresented: $onboarding) {
                    OnboardingView(isOnboarding: $isOnboarding, health: health)
                }
            }
            Section("Beta Testing") {
                Button {
                    var testData = [HealthData]()
                    if health.healthData.count < 10 {
                    for day in Date.dates(from: Date().addingTimeInterval(.month * 4), to: Date()) {
                        var vals = [HealthDataPoint]()
                        for hour in Date.datesHourly(from: day, to: day.addingTimeInterval(-.day)) {
                            vals.append(HealthDataPoint(date: hour, value: Double.random(in: 60...120)))
                        }
                        
                        testData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: "", date: day, endDate: day, data: health.average(numbers: vals.map{$0.value}), risk: 0, dataPoints: vals, context: "TEST"))
                    }
                        let sorted = testData.sorted(by: { a, b in
                            return a.date < b.date
                        })
                      
                        for type in HKQuantityTypeIdentifier.Vitals.filter({$0.type == .heartRate}) {
                            health.outliers(for: type, unit: HKUnit(from: "count/min"), with:  Date().addingTimeInterval(.month * 4), to: Date(), testData: sorted)
                        
                    }
                    }
                } label: {
                    Text("Populate Health Data")
                }
            } .navigationTitle("Settings")
        } .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
            .sheet(isPresented: $details) {
                VStack {
                HStack {
                    
                    Button {
                        details = false
                    } label: {
                        Image(systemSymbol: .xmark)
                            .font(.headline)
                    } .padding()
                    Spacer()
                }
                PrivacyReportView()
                }
            }
    }
}

struct HealthQuery: Codable {
    var health: [HealthData]
}
