//
//  DataViewv2.swift
//  DataViewv2
//
//  Created by Andreas on 9/3/21.
//

import SwiftUI
import SFSafeSymbols
import TabularData
struct DataViewv2: View {
    @Environment(\.calendar) var calendar
    @ObservedObject var health: Healthv3
    private var year: DateInterval {
        calendar.dateInterval(of: .year, for: Date())!
    }
    @State var share = false
    var body: some View {
        VStack {
            HStack {
                
                Button(action: {
                    health.getWhenAsleep()
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
                        
                        
                        let earlyDate = health.healthData.map{$0.date}.min()
                        let laterDate = health.healthData.map{$0.date}.max()
                        if let earlyDate = earlyDate {
                            if let laterDate = laterDate {
                                health.codableRisk = []
                                for date in Date.dates(from: earlyDate, to: laterDate) {
                                    
                                    
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
#warning("reenable")
                                        // health.getRiskScorev2(date: Date())
                                    }
                                }
                                
                            }
                            
                        }
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
            
          
            let riskData = health.riskData.sliced(by: [.day, .month, .year], for: \.date)
            CalendarView(health: health, interval: year) { date in
                let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
                let date2 = Calendar.current.date(from: components)!
                
                Text(String(self.calendar.component(.day, from: date)))
                    .frame(width: 40, height: 40, alignment: .center)
                    .background((date < Date() && (riskData[date2]?.count ?? 0) > 0) ? ((health.average(numbers: riskData[date2]?.map{$0.risk ?? .nan}.filter{$0.isNormal} ?? [0.0]) ) > 0) ? .red : .green : .white)
                    .foregroundColor((date < Date() && (riskData[date2]?.count ?? 0) > 0) ? ((health.average(numbers: riskData[date2]?.map{$0.risk ?? .nan}.filter{$0.isNormal} ?? [0.0]) ) > 0) ? .white : .white : .gray.opacity(0.6))
                
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            
        }}
    
}


