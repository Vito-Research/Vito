//
//  PrivacyReportView.swift
//  Vito
//
//  Created by Andreas Ink on 3/31/22.
//

import SwiftUI

struct PrivacyReportView: View {
    let apiCalls = [Explanation(image: .arrowDown, explanation: "Fitbit API", detail: "Used to autheticate, request, and get data from your Fitbit"), Explanation(image: .arrowDown, explanation: "Fitbit Redirect Website", detail: "Used to access your Fitbit authetication token")]
    
    let howTo = [Explanation(image: .lock, explanation: "Open Settings on Your iPhone", detail: ""), Explanation(image: .lock, explanation: "Navigate to Privacy", detail: ""), Explanation(image: .lock, explanation: "Scroll down to App Privacy Report and tap on it", detail: ""), Explanation(image: .lock, explanation: "Press Show All and Find Vito (should be near the bottom)", detail: "")]
    var body: some View {
        Form {
            Section {
            Image("secure")
                .resizable()
                .padding()
                
                .scaledToFit()
                .background(LinearGradient(colors: [.accentColor, .cyan], startPoint: SwiftUI.UnitPoint.topLeading, endPoint: SwiftUI.UnitPoint.bottomTrailing).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.vertical, 15))
            }
            Section {
                VStack(alignment: .leading) {
        Text("Privacy is Important.")
                        .font(.custom("Poppins-Bold", size: 24, relativeTo: .headline))
                        .padding(.vertical)
                        .foregroundColor(Color.accentColor)
        Text("Here's how to see what network requests Vito makes according to Apple...")
                        .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                        .foregroundColor(Color.cyan)
                   
        ForEach(howTo, id: \.self) { value in
            HStack {
               
                Image(systemSymbol: value.image)
                    .foregroundColor(Color(value.explanation == "Your heart rate while asleep is abnormally high compared to your previous data" ? "red" : "text"))
                
                Text(value.explanation)
                
                    .foregroundColor(Color(value.explanation == "Your heart rate while asleep is abnormally high compared to your previous data" ? "red" : "text"))
            .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                Spacer()
            } .padding(.vertical)
        }
                } .fixedSize(horizontal: false, vertical: true)
                }
         //   }
            Section  {
                VStack(alignment: .leading) {
        Text("TLDR...")
                        .font(.custom("Poppins-Bold", size: 24, relativeTo: .headline))
                        .foregroundColor(Color.accentColor)
        ForEach(apiCalls, id: \.self) { value in
        HStack {
           
            Image(systemSymbol: value.image)
                .foregroundColor(Color(value.explanation == "Your heart rate while asleep is abnormally high compared to your previous data" ? "red" : "text"))
            VStack(alignment: .leading) {
            Text(value.explanation)
            
                .foregroundColor(Color(value.explanation == "Your heart rate while asleep is abnormally high compared to your previous data" ? "red" : "text"))
        .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
            
            Text(value.detail)
            
                .foregroundColor(Color(value.detail == "Your heart rate while asleep is abnormally high compared to your previous data" ? "red" : "text"))
        .font(.custom("Poppins-Bold", size: 14, relativeTo: .headline))
            }
            Spacer()
        } .padding(.vertical)
        }
        } .fixedSize(horizontal: false, vertical: true)
    .padding(.top)
    }
}
    }
}
struct PrivacyReportView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyReportView()
    }
}
