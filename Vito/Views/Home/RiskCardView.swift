//
//  RiskCardView.swift
//  RiskCardView
//
//  Created by Andreas on 8/18/21.
//

import SwiftUI
import SFSafeSymbols
struct RiskCardView: View {
    @ObservedObject var health: Healthv3
    @State var min: CGFloat = UserDefaults.standard.double(forKey: "minRisk")
    @State var max: CGFloat = UserDefaults.standard.double(forKey: "maxRisk")
    @State var explain = true
    @State var learnMore = false
    @State var openData = false
    @State var date = Date()
    
    @State var risk = Risk(id: "nodata", risk: 21.0, explanation: [Explanation]())
    
    @State var isCalendar = false
    var body: some View {
        VStack {
            if !isCalendar {
            HStack {
                NavigationLink(destination: DataViewv2(health: health)) {
                 
                    Image(systemSymbol: .chartBar)
                        .font(.title)
                        
                }
                
               
                Text("Heart Rate Score")
                    .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                Spacer()
               
                NavigationLink(destination: PrivacyReportView()) {
                 
                    Image(systemSymbol: .questionmarkCircle)
                        .font(.largeTitle)
                        
                }
                
            }
            }
            
            HalvedCircularBar(progress: $risk.risk, health: health, min: $min, max: $max)
               
            
                
               
            if !isCalendar {
            if explain {
                ZStack {
                    Color(UIColor.systemBackground)
                    VStack {
                //LazyVGrid(columns: [GridItem(), GridItem()]) {
                        VStack {
                ForEach(health.risk.explanation, id: \.self) { value in
                    
                    HStack {
                       
                        Image(systemSymbol: value.image)
                            .foregroundColor(Color(value.explanation == "Your heart rate while asleep is abnormally high compared to your previous data" ? "red" : "text"))
                        
                        Text(value.explanation)
                        
                            .foregroundColor(Color(value.explanation == "Your heart rate while asleep is abnormally high compared to your previous data" ? "red" : "text"))
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
            .onAppear() {

            }
            .onChange(of: date) { value in
            }
    }
    func getHeartRateData() -> [HealthData] {

        let components = Calendar.current.dateComponents(health.queryDate.durationType == .Month ? [.month, .year] : health.queryDate.durationType == .Week ? [.weekOfMonth, .month, .year] : [.day, .month, .year], from: health.queryDate.anchorDate)
        let date = Calendar.current.date(from: components)!
       
        return (health.queryDate.durationType == .Month ? health.hrData.sliced(by: [.month, .year], for: \.date)[date] : health.queryDate.durationType == .Week ? health.hrData.sliced(by: [.weekOfMonth, .month, .year], for: \.date)[date] : health.hrData.sliced(by: [.day, .month, .year], for: \.date)[date]) ?? [HealthData]()
    }
}

import SwiftUI

struct HalvedCircularBar: View {
    
    @Binding var progress: CGFloat
    @ObservedObject var health: Healthv3
    @Binding var min: CGFloat
    @Binding var max: CGFloat
    
    
    var body: some View {
        VStack {
            
            if progress != 21 {
            ZStack {
                
                RoundedRectangle(cornerRadius: 10)
                    .trim(from: 0.0, to: 1.0)
                    .foregroundColor(Color(progress > 0.8 ? "red" : "green"))
                   
                    .opacity(0.8)
                    .frame( height: 125)
                    .padding(.vertical)
                  
               
                Text(progress == 21 ? "Not Enough Data" : progress > 0.5 ? "Alert" : "OK")
                    .font(.custom("Poppins-Bold", size: 20, relativeTo: .headline))
                  
                    .foregroundColor(.white)

                
            } .onAppear() {
                print(progress)

               
            }
            } else {
                Text(progress == 21 ? "Not Enough Data" : "\(Int((progress)*100))%")
                    .font(.custom("Poppins-Bold", size: 20, relativeTo: .headline))
                    .foregroundColor(Color("blue"))
                    .frame( height: 125)
                    .padding(.vertical)
            }
        } .onAppear() {
            let riskData = health.riskData.sliced(by: [.day, .month, .year], for: \.date)
            let components = Calendar.current.dateComponents([.day, .month, .year], from: health.queryDate.anchorDate)
            let date2 = Calendar.current.date(from: components)!
            progress = CGFloat(riskData[date2]?.map{$0.risk ?? .nan}.filter{$0.isNormal}.last ?? 0.0)
        }
    }
    
  
}
