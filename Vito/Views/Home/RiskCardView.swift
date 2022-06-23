//
//  RiskCardView.swift
//  RiskCardView
//
//  Created by Andreas on 8/18/21.
//

import SwiftUI
import SFSafeSymbols
import VitoKit

struct RiskCardView: View {
   
    @ObservedObject var health: Vito
    
    @State var min: CGFloat = UserDefaults.standard.double(forKey: "minRisk")
    @State var max: CGFloat = UserDefaults.standard.double(forKey: "maxRisk")
    @State var explain = true
    @State var learnMore = false
    @State var openData = false
    @State var date = Date()
    
    @State var risk = Risk(id: "nodata", risk: 21.0, explanation: [Explanation]())
    
    @State var isCalendar = false
    @State var scale = 0.8
    @Binding var healthData: HealthData

    var body: some View {
        VStack {
            if !isCalendar {
            HStack {
                NavigationLink(destination: DataViewv2(health: health)) {
                 
                    Image(systemSymbol: .chartBar)
                        .font(.title)
                        .scaleEffect(scale)
                        .onAppear() {
                            withAnimation(.beat.delay(0.5)) {
                                scale = 1.0
                            }
                            withAnimation(.beat.delay(1.0)) {
                                scale = 1.0
                            }
                           
                        }
                }
                
      
                   
                Text("Heart Rate Score")
                    .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
               
                NavigationLink(destination: SettingsView(health: health)) {
                 
                    Image(systemSymbol: .gear)
                        .font(.largeTitle)
                        .scaleEffect(scale)
                        
                }
                
            }
            }
            
            HalvedCircularBar(data: healthData, progress: $healthData.risk, health: health, min: $min, max: $max, date: date)

            if !isCalendar {
            if explain {
                ZStack {
                    Color(UIColor.systemBackground)
                    VStack {

                        VStack {
                ForEach(health.risk.explanation, id: \.self) { value in
                    
                    HStack {
                       
                        Image(systemSymbol: value.image)
                            .foregroundColor(Color(value.explanation == "Your heart rate while asleep is abnormally high compared to your previous data" ? "red" : "text"))
                        
                        Text(value.explanation)
                        
                            .foregroundColor(Color(value.explanation == "Your heart rate while asleep is abnormally high compared to your previous data" ? "red" : "text"))
                            .fixedSize(horizontal: false, vertical: true)
                    .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                        Spacer()
                    }
                .padding(.top)
                    Divider()
                }
                } .transition(.move(edge: .top))

            }
                }
            }
            }
        } .padding()
        
        
    }

}

import SwiftUI

struct HalvedCircularBar: View {
    @State var data: HealthData
    @Binding var progress: Int
    @ObservedObject var health: Vito
    @Binding var min: CGFloat
    @Binding var max: CGFloat
    
    @State var heartScale = 0.8
    
    @State var date: Date
    var body: some View {
        VStack {
            
            if progress != 21 {
            ZStack {
                
                RoundedRectangle(cornerRadius: 10)
                    .trim(from: 0.0, to: 1.0)
                    .foregroundColor(Color(progress > Int(0.8) ? "red" : "green"))
                   
                    .opacity(0.8)
                    .frame( height: 125)
                    .padding(.vertical)
                  
                HStack {
                    Image(systemSymbol: .heart)
                        .font(.title)
                        .scaleEffect(heartScale)
                        .foregroundColor(.white)
                        .onAppear() {
                            withAnimation(.beat.delay( progress == 1 ? 0.0 : 1.0).repeatForever()) {
                                heartScale = 1.0
                            }
                           
                           
                        }
                    
                    Text(progress == 21 ? "Not Enough Data" : progress == 1 ? "Alert" : "OK")
                    .font(.custom("Poppins-Bold", size: 20, relativeTo: .headline))
                  
                    .foregroundColor(.white)

                }
            }
            } else {
                Text(progress == 21 ? "Not Enough Data" : "\(Int((progress)*100))%")
                    .font(.custom("Poppins-Bold", size: 20, relativeTo: .headline))
                    .foregroundColor(Color("blue"))
                    .frame( height: 125)
                    .padding(.vertical)
            }
        }
    }
    
  
}
