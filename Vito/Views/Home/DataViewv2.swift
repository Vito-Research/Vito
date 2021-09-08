//
//  DataViewv2.swift
//  DataViewv2
//
//  Created by Andreas on 9/3/21.
//

import SwiftUI

struct DataViewv2: View {
    @Environment(\.calendar) var calendar
    @ObservedObject var health: Health
    private var year: DateInterval {
        calendar.dateInterval(of: .year, for: Date())!
     }
   
    var body: some View {
        
        HStack {
            
                CalendarView(interval: year) { date in
                      Text(String(self.calendar.component(.day, from: date)))
                        .frame(width: 40, height: 40, alignment: .center)
                        .background(Color((health.codableRisk.filter{$0.date.get(.day) == date.get(.day) && $0.date.get(.month) == date.get(.month) }.last?.id.isEmpty ?? true) ? "blue" : ((health.codableRisk.filter{$0.date.get(.day) == date.get(.day)}.last?.risk ?? 0) > 0.5 ? "red" : "green")))
                        .foregroundColor(.white)
                        .clipShape(Rectangle())
                       
                    }
        }
          
    }
}

