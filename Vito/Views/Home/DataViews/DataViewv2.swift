//
//  DataViewv2.swift
//  DataViewv2
//
//  Created by Andreas on 9/3/21.
//

import SwiftUI
import SFSafeSymbols
import TabularData
import VitoKit
struct DataViewv2: View {
    @Environment(\.calendar) var calendar
    @ObservedObject var health: Vito
    private var year: DateInterval {
        calendar.dateInterval(of: .year, for: Date())!
    }
    @State var share = false
    @State var data: HealthData?
    var body: some View {
        VStack {
            HStack {
                
                Button(action: {
                   // health.sync()
                    //health.backgroundDelivery()
                }) {
                    Label("Sync", systemSymbol: .repeat)
                        .font(.custom("Poppins", size: 16, relativeTo: .subheadline))
                }
                Spacer()
                if #available(iOS 15, *) {
                    Button(action: {
                        
                        if let filepath = Bundle.main.path(forResource: "P355472-AppleWatch-hr", ofType: "csv") {
                            do {
                                
                                // health.healthData  = []
                                // ML().importCSV(data: try DataFrame(contentsOfCSVFile: URL(fileURLWithPath: filepath))) { healthData in
                                //  health.healthData = healthData
                                //  }
                                
                            } catch {
                                // contents could not be loaded
                            }
                        } else {
                            // example.txt not found!
                            print("OOOOoof")
                        }
                        
                        
//                        let earlyDate = health.healthData.map{$0.date}.min()
//                        let laterDate = health.healthData.map{$0.date}.max()
//                        if let earlyDate = earlyDate {
//                            if let laterDate = laterDate {
//                                health.codableRisk = []
//                                for date in Date.dates(from: earlyDate, to: laterDate) {
//
//
//
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//#warning("reenable")
//                                        // health.getRiskScorev2(date: Date())
//                                    }
//                                }
//
//                            }
//
//                        }
                        //                    let earlyDate = Calendar.current.date(
                        //                      byAdding: .month,
                        //                      value: -3,
                        //                      to: Date()) ?? Date()
                        //                    health.codableRisk = []
                        //                    for date in Date.dates(from: earlyDate, to: Date()) {
                        //                   let risk = health.getRiskScorev2(date: date)
                        //                        //health.codableRisk.append(CodableRisk(id: risk.id, date: date, risk: risk.risk, explanation: []))
                        //                    }
                        //
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            // ML().exportDataToCSV(data: health.healthData, codableRisk: health.codableRisk) { _ in
                            share = true
                            //   }
                        }
                        
                    }) {
                        //                    Label("Export", systemSymbol: .paperplane)
                        //                        .font(.custom("Poppins", size: 16, relativeTo: .subheadline))
                    }
                    .sheet(isPresented: $share) {
                        //  ShareSheet(activityItems: [ML().getDocumentsDirectory().appendingPathComponent("Vito_Health_Data.csv"), ML().getDocumentsDirectory().appendingPathComponent("Vito_Risk_Data.csv")])
                        
                    }
                }
            } .padding()
            
          
         //   let riskData = health.healthData.sliced(by: [.day, .month, .year], for: \.date)
            
            CalendarView(health: health, interval: year) { date in
                Button(String(self.calendar.component(.day, from: date))) {
                    data = health.healthData.filter{$0.date.asDay() == date.asDay()}.first
                }
             
                    .frame(width: 40, height: 40, alignment: .center)
                    .foregroundColor(Color.white)
                    .background(content: {
                        Group {
                        if (health.healthData.filter{$0.date.asDay() == date.asDay()}.map{$0.risk}.filter{$0 == 1}.count ) > 0 {
                            Color("red")
                        } else if !(health.healthData.filter{$0.date.asDay() == date.asDay()}.isEmpty) {
                            Color("green")
                        } else {
                            Color("back")
                        }
                        } .clipShape(RoundedRectangle(cornerRadius: 10)) //.animation(.beat, value: health.healthData.filter{$0.date.asDay() == date.asDay()})
                    })
                    .id(date)
                    .sheet(item: $data) { data in
                        DataView(data2: data, health: health)
                    }
                       
                    }
                  
                    .onAppear() {
                        //print(riskData)
                    }
//                    .background((date < Date() && (riskData[date]?.count ?? 0) > 0) ? ((health.average(numbers: riskData[date]?.map{Double($0.risk )}.filter{$0.isNormal} ?? [0.0]) ) > 0) ?  Color("red") :  Color("green") :  Color("back"))
//                    .foregroundColor((date < Date() && (riskData[date2]?.count ?? 0) > 0) ? ((health.average(numbers: riskData[date]?.map{Double($0.risk )}.filter{$0.isNormal} ?? [0.0]) ) > 0) ? Color("text") : Color(.white) : Color(.white))
                    //.animation(.beat, value: riskData[date2])
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            
        }
}


