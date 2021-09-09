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
    
    @State var onboardingViews = [Onboarding(id: UUID(), image: "data", title: "Your Heart Rate While Asleep is an Indicator of Health", description: "A higher heart rate while asleep may indicate signs of distress from your body"), Onboarding(id: UUID(), image: "data", title: "Types of Data", description: "Learn how you can use your data by tapping the data below."), Onboarding(id: UUID(), image: "doc", title: "Always Consult With Your Doctor", description: "This is not a medical app, therefore it does not provide medical advice or diagnose anyone, rather a health app that allows the user to learn more about their data and discuss it with their doctor.")]
    @State var slideNum = 0
    @Binding var isOnboarding: Bool
    @Binding var isOnboarding2: Bool
    @State var time = 0
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
                    isOnboarding = true
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
                   isOnboarding = true
                   UserDefaults.standard.set(true, forKey: "onboarding")
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
                .frame(width: .infinity)
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
            
            Image(onboarding.image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                .rotation3DEffect(.degrees(3), axis: (x: 0, y: 1, z: 0))
                .shadow(color: Color(.lightGray).opacity(0.4), radius: 40)
            
           
            if onboarding.image == "data" {
                DataTypesListView()
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

