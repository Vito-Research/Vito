//
//  DataViewv2.swift
//  DataViewv2
//
//  Created by Andreas on 9/3/21.
//

import SwiftUI
import SFSafeSymbols
struct DataViewv2: View {
    @Environment(\.calendar) var calendar
    @ObservedObject var health: Health
    private var year: DateInterval {
        calendar.dateInterval(of: .year, for: Date())!
     }
   @State var share = false
    var body: some View {
        VStack {
            HStack {
              
                Button(action: {
                    let earlyDate = Calendar.current.date(
                      byAdding: .month,
                      value: -3,
                      to: Date()) ?? Date()
                    health.codableRisk = []
                    for date in Date.dates(from: earlyDate, to: Date()) {
                   let risk = health.getRiskScorev2(date: date)
                        health.codableRisk.append(CodableRisk(id: risk.id, date: date, risk: risk.risk, explanation: []))
                    }
                }) {
                    Label("Sync", systemSymbol: .repeat)
                        .font(.custom("Poppins", size: 16, relativeTo: .subheadline))
                }
                Spacer()
                if #available(iOS 15, *) {
                Button(action: {
                    let earlyDate = Calendar.current.date(
                      byAdding: .month,
                      value: -3,
                      to: Date()) ?? Date()
                    health.codableRisk = []
                    for date in Date.dates(from: earlyDate, to: Date()) {
                   let risk = health.getRiskScorev2(date: date)
                        health.codableRisk.append(CodableRisk(id: risk.id, date: date, risk: risk.risk, explanation: []))
                    }
                   
                    ML().exportDataToCSV(data: health.healthData, codableRisk: health.codableRisk) { _ in
                            share = true
                        }
                   
                }) {
                    Label("Export", systemSymbol: .paperplane)
                        .font(.custom("Poppins", size: 16, relativeTo: .subheadline))
                }
                .sheet(isPresented: $share) {
                    ShareSheet(activityItems: [ML().getDocumentsDirectory().appendingPathComponent("Vito_Health_Data.csv"), ML().getDocumentsDirectory().appendingPathComponent("Vito_Risk_Data.csv")])
                    
                }
                }
            } .padding()
               
        HStack {
            
            CalendarView(health: health, interval: year) { date in
                      Text(String(self.calendar.component(.day, from: date)))
                        .frame(width: 40, height: 40, alignment: .center)
                        .background(Color(date > Date() ? "" : (health.codableRisk.filter{ $0.date.get(.day) == date.get(.day) && $0.date.get(.month) == date.get(.month) }.last?.risk == 21.0) ? "" : ((health.codableRisk.filter{$0.date.get(.day) == date.get(.day)}.last?.risk ?? 0) > 0.5 ? "red" : "green")))
                        .foregroundColor(Color(date > Date() ? .systemBlue : (  health.codableRisk.filter{$0.date.get(.day) == date.get(.day) && $0.date.get(.month) == date.get(.month) }.last?.risk == 21.0) ? .systemBlue : ((health.codableRisk.filter{$0.date.get(.day) == date.get(.day)}.last?.risk ?? 0) > 0.5 ? .white :  .white)))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                       
                    }
        }}
          
    }
}

