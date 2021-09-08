//
//  HomeView.swift
//  HomeView
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
import TabularData
import CoreML

struct HomeView: View {
    @State private var orientation = UIDeviceOrientation.unknown
    @State var gridLayout: [GridItem] = [ ]
    @ObservedObject var health: Health
    //@ObservedObject var ml: ML
    @State var enrolled = UserDefaults.standard.bool(forKey: "enrolled")
    @State var share = false
    var body: some View {
        NavigationView {
        ScrollView {
            LazyVGrid(columns: gridLayout) {
                if !health.risk.id.isEmpty {
                RiskCardView(health: health)
                        .transition(.move(edge: .top))
                }

                
            }
        } .navigationTitle("")
                .navigationBarHidden(true)
        .onAppear() {
            if UIDevice.current.userInterfaceIdiom == .pad {
                print("iPad")
                self.gridLayout = [GridItem(), GridItem(.flexible())]
            } else {
                self.gridLayout =  [GridItem(.flexible())]
            }
        }
        .onRotate { newOrientation in
            orientation = newOrientation
            if UIDevice.current.userInterfaceIdiom == .phone {
                if !orientation.isFlat {
                    self.gridLayout = (orientation.isLandscape) ? [GridItem(), GridItem(.flexible())] :  [GridItem(.flexible())]
                }
            }
        }
        }
        .onAppear() {
        }
            
               //if type == .heartRate {
//                exportDataToCSV(data: health.healthData) { _ in
//                               DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                               share = true
//                               }
//
//                           }
            
               
               
                
            
//        .onReceive(health.healthData.publisher) { value in
//            exportDataToCSV(data: health.healthData) { _ in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                share = true
//                }
//
//           // }
//        }
//        }
        .sheet(isPresented: $share) {
            //ShareSheet(activityItems: [ml.getDocumentsDirectory().appendingPathComponent("A.csv")])
            
        }
    }
//    func exportDataToCSV(data: [HealthData], completionHandler: @escaping (Bool) -> Void) {
//        DispatchQueue.main.async {
//        var trainingData = DataFrame()
//        let filteredToHeartRate = data.filter { data in
//            return data.title == HKQuantityTypeIdentifier.heartRate.rawValue
//        }
//        let filteredToNight = filteredToHeartRate.filter { data in
//            return data.date.get(.hour) >  12 && data.date.get(.hour) <  8
//        }
//        let nightlyHeartRateColumn = Column(name: "Heartrate", contents: filteredToNight)
//        trainingData.append(column: nightlyHeartRateColumn)
//        do {
//            try trainingData.writeCSV(to: ml.getDocumentsDirectory().appendingPathComponent("A.csv"))
//            print(ml.getDocumentsDirectory().appendingPathComponent("A.csv").dataRepresentation)
//        } catch {
//            print(error)
//            
//        }
//        completionHandler(true)
//    }
//    }
    func openDataSharingAgreement() {
        
    }
}

