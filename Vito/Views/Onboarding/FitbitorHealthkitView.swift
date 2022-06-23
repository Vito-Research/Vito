//
//  FitbitorHealthkitView.swift
//  Vito
//
//  Created by Andreas Ink on 6/23/22.
//

import SwiftUI
import VitoKit
import HealthKit
struct FitbitOrHealthkitView: View {
    @ObservedObject var health: Vito
    @Binding var isOnboarding: Int
    var body: some View {
        VStack {
            Text("Fitbit or Apple Watch?")
                .font(.custom("Poppins", size: 24, relativeTo: .title))
                .foregroundColor(Color.accentColor)
            Text("Please select your device below")
                .font(.custom("Poppins", size: 18, relativeTo: .subheadline))
        HStack {
            Button {
                health.fitbit = true
                isOnboarding += 1
                UserDefaults.standard.set(true, forKey: "onboarding")
                
                for type in HKQuantityTypeIdentifier.Vitals.filter({$0.type == .heartRate}) {
                    
                    health.outliers(for: type, unit: type.unit, with: Date().addingTimeInterval(.month * 4), to: Date(), filterToActivity: .active)
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .gradientForeground(colors: [Color("blue"), Color("teal")])
                    Text("Fitbit")
                        .foregroundColor(.white)
                }
            }

            Spacer()
            
            Button {
                health.fitbit = false
                isOnboarding += 1
                UserDefaults.standard.set(true, forKey: "onboarding")
                for type in HKQuantityTypeIdentifier.Vitals.filter({$0.type == .heartRate}) {
                    
                    health.outliers(for: type, unit: type.unit, with: Date().addingTimeInterval(.month * 4), to: Date(), filterToActivity: .active)
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .gradientForeground(colors: [Color("teal"), Color("blue")])
                    Text("Apple Watch")
                        .foregroundColor(.white)
                }
            }
        } .padding()
            .font(.custom("Poppins", size: 24, relativeTo: .headline))
    }
    }
}
