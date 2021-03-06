//
//  OnboardingView.swift
//  OnboardingView
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import NiceNotifications
import HealthKit
import VitoKit

struct OnboardingView: View {
    let healthStore = HKHealthStore()
    
    @State var onboardingViews = [Onboarding(id: UUID(), image: "bird", title: "Detect Stress", description: "A higher heart rate while asleep may indicate signs of distress from your body"), Onboarding(id: UUID(), image: "data", title: "Infection = Changes in Smartwatch Data", description: "Learn how you can use your data by tapping the data below.", toggleData: [ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .heart, explanation: "Heart Rate", detail: "Abnormally high heart rate while asleep may be a sign of distress from your body")), ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .lungs, explanation: "Respiratory Rate", detail: "High respiratory rate while asleep may be a sign of distress from your body")), ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .oCircle, explanation: "Blood Oxygen", detail: "Lower blood oxygen may be a sign of distress from your body")), ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .heartFill, explanation: "Heart Rate Variability", detail: "Lower heart rate variability may be a sign of distress from your body"))]), Onboarding(id: UUID(), image: "privacy", title: "Privacy is Vital", description: "Here's how we protect your privacy...", toggleData: [ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .person, explanation: "You Are In Control", detail: "Your data is your data, you can delete it or modify it at anytime")), ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .lock, explanation: "By Default, Data is Stored and Processed On-Device", detail: "All data is saved on-device")), ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .paperplane, explanation: "Sharing Data is Optional And When Shared is Anonymous and Encrypted", detail: "Privacy is vital. We do collect data upon opt-in to help refine our algorithm."))]), Onboarding(id: UUID(), image: "doc", title: "Always Consult With Your Doctor", description: "This is not a medical app, therefore it does not provide medical advice or diagnose anyone, rather a health app that allows the user to learn more about their data and discuss it with their doctor."),  Onboarding(id: UUID(), image: "fitbitorhealth", title: "Always Consult With Your Doctor", description: "This is not a medical app, therefore it does not provide medical advice or diagnose anyone, rather a health app that allows the user to learn more about their data and discuss it with their doctor.")]

    @State var slideNum = 0
    @Binding var isOnboarding: Int
    @State var time = 0
    @ObservedObject var health: Vito
    //@Binding var setting: Setting
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            HStack {
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemSymbol: .xmark)
                        .font(.headline)
                } .padding()
                Spacer()
            }
            TabView(selection: $slideNum) {
                ForEach(onboardingViews.indices, id: \.self) { i in
                    if onboardingViews[i].image == "fitbitorhealth" {
                        FitbitOrHealthkitView(health: health, isOnboarding: $isOnboarding)
                            .tag(i)
                    } else {
                    OnboardingDetail(onboarding: onboardingViews[i], vito: health)
                        .tag(i)
                }
                }
               
            }
            .tabViewStyle(PageTabViewStyle())
            if onboardingViews[slideNum].title.contains("Can") {
            Button(action: {
                if slideNum + 1 < onboardingViews.count  {
                    slideNum += 1
                } else {
                    slideNum = 0
                    // dismiss sheet
//                    isOnboarding += 1
//                    UserDefaults.standard.set(true, forKey: "onboarding")
                    
                }
             
            }) {
                ZStack {

                    Text("No")
                        .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                        .foregroundColor(.white)
                }
            } .buttonStyle(CTAButtonStyle())
                    .frame(width: .infinity)
                    .padding()
            }
            
            Button(action: {
                if onboardingViews[slideNum].title.contains("Noti") {
                    LocalNotifications.requestPermission(strategy: .askSystemPermissionIfNeeded) { success in
                        if success {

                        }
                    }
                    
                } else if onboardingViews[slideNum].toggleData.map{$0.explanation.image}.contains(.heart) {
                    health.auth(selectedTypes: [.Vitals])
                }
                if slideNum + 1 < onboardingViews.count  {
                    slideNum += 1
                } else {
                    slideNum = 0
                    // dismiss sheet
//                   isOnboarding += 1
//                   UserDefaults.standard.set(isOnboarding, forKey: "onboarding")
//                    for type in HKQuantityTypeIdentifier.Vitals {
//
//                        health.outliers(for: type, unit: type.unit, with: Date().addingTimeInterval(.month * 4), to: Date(), filterToActivity: .active)
//                    }
                }
                
            }) {
                 if onboardingViews[slideNum].title == "Learn More" {
                    Link("Learn More", destination: URL(string: "http://vito-website.vercel.app/")!)
                 } else {
                ZStack {
                     
                    Text(onboardingViews[slideNum].title.contains("Can") ? "Yes" : "Continue")
                        .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                        .foregroundColor(.white)
                    
                }
                 }
            } .buttonStyle(CTAButtonStyle())
             
                .padding()
            
        }
    }
}

struct OnboardingDetail: View {
    @State var onboarding: Onboarding
    @ObservedObject var vito: Vito
    var body: some View {
        ScrollView(showsIndicators: false) {
        VStack {
            Text(onboarding.title)
                .font(.custom("Poppins-Bold", size: 24, relativeTo: .title))
                .multilineTextAlignment(.center)
                .padding(.bottom)
                
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color.accentColor)
            Text(onboarding.description)
                .font(.custom("Poppins-Bold", size: 18, relativeTo: .subheadline))
                .opacity(0.8)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
            if !onboarding.image.isEmpty {
            Image(onboarding.image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                .rotation3DEffect(.degrees(3), axis: (x: 0, y: 1, z: 0))
                .shadow(color: Color(.lightGray).opacity(0.4), radius: 40)
            }
           
            if !onboarding.toggleData.isEmpty {
                DataTypesListView(toggleData: onboarding.toggleData, title: "", caption: "", showBtn: false, vito: vito)
               
            }
        }
        }
        .padding()
    }
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

