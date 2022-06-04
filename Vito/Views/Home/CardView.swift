//
//  CardView.swift
//  CardView
//
//  Created by Andreas on 8/18/21.
//

import SwiftUI

struct CardView: View {
    @State var card: Card
    @State var onboarding = [Onboarding(id: UUID(), image: "bird", title: "We at Vito Believe Health And Privacy are Vital...", description: "We envision a world where you control your health data and can learn from it."), Onboarding(id: UUID(), image: "", title: "Our Core Values...", description: "", toggleData: [ToggleData(id: UUID(), toggle: true, explanation: Explanation(image: .heart, explanation: "Accessibility", detail: "Access to information taliored to you is important to maintain your health so we strive to create greater access to information regarding your health.")), ToggleData(id: UUID(), toggle: true, explanation: Explanation(image: .lock, explanation: "Privacy", detail: "Privacy is vital to Vito, check out our website for more info.")), ToggleData(id: UUID(), toggle: true, explanation: Explanation(image: .person, explanation: "People", detail: "We value people and we all have people who we care about, that's why we built this app."))]), Onboarding(id: UUID(), image: "bird", title: "Learn More", description: "Explore Vito's website?", toggleData: [])]
    @State var show = false
    @State var i = 0
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
                .foregroundColor(Color(UIColor.systemGroupedBackground))
            HStack {
                Image(card.image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                VStack {
                    HStack {
                        Spacer()
                    Text(card.title)
                        .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                        .multilineTextAlignment(.trailing)
                    } .padding(.bottom)
                    HStack {
                        Spacer()
                    Text(card.description)
                        .font(.custom("Poppins", size: 14, relativeTo: .headline))
                        .multilineTextAlignment(.trailing)
                }
                    HStack {
                        Spacer()
                        Button(action: {
                            show = true
                        }) {
                        Text(card.cta)
                                .minimumScaleFactor(0.8)
                    } .buttonStyle(CTAButtonStyle())
                        
                    } .sheet(isPresented: $show) {
                        OnboardingView(onboardingViews: onboarding, isOnboarding: $i, health: Healthv3())
                            .onChange(of: i) { value in
                                if i > 0 {
                                    show = false
                                }
                            }
                    }
                } .padding(.trailing)
            } .padding(.vertical)
        }
    }
}

