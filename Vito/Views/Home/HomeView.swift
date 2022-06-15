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
import VitoKit

struct HomeView: View {
    @State private var orientation = UIDeviceOrientation.unknown
    @State var gridLayout: [GridItem] = [ ]
    @ObservedObject var health:  Vito
    @State var healthData = HealthData(id: "", type: .Health, title: "", text: "", date: Date(), endDate: Date(), data: 0, risk: 21, dataPoints: [HealthDataPoint]())
    @State var share = false
    @State var risk = Risk(id: UUID().uuidString, risk: 0.0, explanation: [Explanation]())
    var body: some View {
        NavigationView {
    
            VStack {
           
                if !health.risk.id.isEmpty {
                    RiskCardView(health: health, date: Date(), healthData: $healthData)
                        .transition(.move(edge: .top))
                       
                }
                Spacer()
                CardView(health: health, card: Card( image: "data", title: "Learn More?", description: "Learn more about our values and how the algorithm works", cta: "Learn More"))
                    .padding()
                  
                Spacer()
            }

                .navigationTitle("")
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
        .onChange(of: health.healthData, perform: { newValue in
            if newValue.last?.date.asDay()?.addingTimeInterval(-.day) == Date().asDay() {
                if let newVal = newValue.last {
                    self.healthData = newVal
                    let alert = [Explanation(image: .stethoscope, explanation: "Not Medical Advice/Diagnosis/Treatment", detail: "Always consult your doctor, this is only a data point to discuss"),
                                 Explanation(image: .heart, explanation: "Heart Rate Higher Than Normal", detail: "Stress may be caused by many things including infection, intense excersise, etc"),
                                 Explanation(image: .checkmark, explanation: "Reasons for an Alert", detail: "Stress may be caused by many things including infection, intense excersise, etc"),
                    ]
                    let ok = [Explanation(image: .stethoscope, explanation: "Not Medical Advice/Diagnosis/Treatment", detail: "Always consult your doctor, this is only a data point to discuss"),
                              Explanation(image: .heart, explanation: "Heart Rate Near Average", detail: "Vito measures your heart rate while alseep to unlock insights into health"),
                              
    
                    ]
                    health.risk = Risk(id: UUID().uuidString, risk: CGFloat(newVal.risk), explanation: newVal.risk == 1 ? alert : ok)
                }
            }
        })
            

        .sheet(isPresented: $share) {
            //ShareSheet(activityItems: [ml.getDocumentsDirectory().appendingPathComponent("A.csv")])
            
        }
    }
    func openDataSharingAgreement() {
        
    }
}

