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
    @ObservedObject var health: Healthv3
   
    @State var share = false
    var body: some View {
        NavigationView {
    
            VStack {
           
                if !health.risk.id.isEmpty {
                RiskCardView(health: health, date: Date())
                        .transition(.move(edge: .top))
                       
                }
                Spacer()
                CardView(card: Card( image: "data", title: "Learn More?", description: "Learn more about our values and how the algorithm works", cta: "Learn More"))
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
            

        .sheet(isPresented: $share) {
            //ShareSheet(activityItems: [ml.getDocumentsDirectory().appendingPathComponent("A.csv")])
            
        }
    }
    func openDataSharingAgreement() {
        
    }
}

