//
//  OnboardingView.swift
//  OnboardingView
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import NiceNotifications
import HealthKit

struct OnboardingView: View {
    let healthStore = HKHealthStore()
    
    @State var onboardingViews = [Onboarding(id: UUID(), image: "bird", title: "Your Heart Rate While Asleep is a Key Indicator of Health", description: "A higher heart rate while asleep may indicate signs of distress from your body"), Onboarding(id: UUID(), image: "data", title: "HR and RR while asleep are indicators of health", description: "Learn how you can use your data by tapping the data below.", toggleData: [ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .heart, explanation: "Heart Rate", detail: "Abnormally high heart rate while asleep can be a sign of distress from your body")), ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .lungs, explanation: "Respiratory Rate", detail: "High respiratory rate while asleep can be a sign of distress from your body")), ToggleData(id: UUID(), toggle: false, explanation:  Explanation(image: .figureWalk , explanation: "Steps", detail: "Utilized to detect when you are alseep")), ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .flame, explanation: "Active Energy", detail: "Utilized to detect when you are alseep"))]), Onboarding(id: UUID(), image: "privacy", title: "Vito Believes Privacy is Vital", description: "Here's how we protect your privacy...", toggleData: [ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .person, explanation: "You Are In Control", detail: "Your data is your data, you can delete it or modify it at anytime")), ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .lock, explanation: "By Default, Data is Stored and Processed On-Device", detail: "All data is saved on-device unless you consent to share your data upon an alert so we can improve the app")), ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .paperplane, explanation: "Sharing Data is Optional And When Shared is Anonymous and Encrypted", detail: "Privacy is vital. We do collect data upon opt-in to help refine our algorithm."))]), Onboarding(id: UUID(), image: "doc", title: "Always Consult With Your Doctor", description: "This is not a medical app, therefore it does not provide medical advice or diagnose anyone, rather a health app that allows the user to learn more about their data and discuss it with their doctor.")]
    //Explanation(image: .paperplane, explanation: "Sharing Data is Optional And When Shared is Anonymous and Encrypted", detail: "Privacy is vital.")
    @State var slideNum = 0
    @Binding var isOnboarding: Int
    @State var time = 0
    @ObservedObject var health: Healthv3
    //@Binding var setting: Setting
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            TabView(selection: $slideNum) {
                ForEach(onboardingViews.indices, id: \.self) { i in
                    OnboardingDetail(onboarding: onboardingViews[i])
                        .tag(i)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            if onboardingViews[slideNum].title.contains("Can") {
            Button(action: {
                if slideNum + 1 < onboardingViews.count  {
                    slideNum += 1
                } else {
                    // dismiss sheet
                    isOnboarding += 1
                    UserDefaults.standard.set(true, forKey: "onboarding")
                    
                }
                //setting.onOff = false
            }) {
                ZStack {
//                    RoundedRectangle(cornerRadius: 25.0)
//                        .foregroundColor(Color(.lightGray))
//                        .frame(height: 75)
//                        .padding()
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
//                            setting.onOff = true
                        }
                    }
                    
                } else if onboardingViews[slideNum].title.contains("Can we Access Your Health Data?") {
                    let readData = Set([
                        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                        HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
                        HKObjectType.quantityType(forIdentifier: .heartRate)!,
                        HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
                        HKObjectType.quantityType(forIdentifier: .stepCount)!
                    ])
                    
                    self.healthStore.requestAuthorization(toShare: [], read: readData) { (success, error) in
                        
                    }
                }
                if slideNum + 1 < onboardingViews.count  {
                    slideNum += 1
                } else {
                    // dismiss sheet
                   isOnboarding += 1
                   UserDefaults.standard.set(isOnboarding, forKey: "onboarding")
                    health.backgroundDelivery()
                }
                
            }) {
                ZStack {
//                    RoundedRectangle(cornerRadius: 25.0)
//                        .foregroundColor(Color("teal"))
//                        .frame(height: 75)
//                        .padding()
                    Text(onboardingViews[slideNum].title.contains("Can") ? "Yes" : "Continue")
                        .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                        .foregroundColor(.white)
                }
            } .buttonStyle(CTAButtonStyle())
               
                .padding()
            
        }
    }
}

struct OnboardingDetail: View {
    @State var onboarding: Onboarding
    
    var body: some View {
        ScrollView(showsIndicators: false) {
        VStack {
            Text(onboarding.title)
                .font(.custom("Poppins-Bold", size: 24, relativeTo: .title))
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .fixedSize(horizontal: false, vertical: true)
            Text(onboarding.description)
                .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                .multilineTextAlignment(.center)
                .padding(.bottom)
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
                DataTypesListView(toggleData: onboarding.toggleData)
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

