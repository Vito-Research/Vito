//
//  DataViewv2.swift
//  DataViewv2
//
//  Created by Andreas on 9/3/21.
//

import SwiftUI
import SFSafeSymbols
import TabularData
import HealthKit
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
                    
                    
                    for type in HKQuantityTypeIdentifier.Vitals {
                        
                        health.outliers(for: type, unit: type.unit, with: Date().addingTimeInterval(.month * 4), to: Date(), filterToActivity: .active)
                    }
                }) {
                    Label("Sync", systemSymbol: .repeat)
                        .font(.custom("Poppins", size: 16, relativeTo: .subheadline))
                }
                Spacer()
               // if #available(iOS 15, *) {
                    Button(action: {
                        
                    
                
#if targetEnvironment(simulator)

#else
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            ML().exportAsCSV(health.healthData)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            share = true
                            }
                        }
                        #endif
                        
                    }) {
                        //                    Label("Export", systemSymbol: .paperplane)
                        //                        .font(.custom("Poppins", size: 16, relativeTo: .subheadline))
                    }
#if targetEnvironment(simulator)

#else
                    .sheet(isPresented: $share) {
      
                        ShareSheet(activityItems: ML().getDocumentsDirectory().appendingPathComponent("HealthData.csv"))
                    }
#endif
              //  }
            } .padding()
            
          
         //   let riskData = health.healthData.sliced(by: [.day, .month, .year], for: \.date)
            if self.health.healthData.count < 5 {
                VStack(alignment: .leading) {
                Text("Loading and Processing Health Data...")
                    .font(.custom("Poppins-Bold", size: 24, relativeTo: .title))
                    .foregroundColor(.accentColor)
                Text("This may take some time, however, you may leave the app and check later")
                    .font(.custom("Poppins-Bold", size: 18, relativeTo: .subheadline))
                  
                } .padding(.leading)
            } else {
            ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 0, maximum: 40)), count: 7), spacing: 0) {
               
                ForEach(Array(zip($health.healthData.filter{$0.date.wrappedValue > Date().addingTimeInterval(.month * 2)}, health.healthData.filter{$0.date > Date().addingTimeInterval(.month * 2)}.indices)), id: \.1) { ($value, i) in
                    if health.healthData.indices.contains(i - 1) {
                        let component = calendar.component(.month, from: value.date)
                        let formatter = component == 1 ? DateFormatter.monthAndYear : .month
                        if health.healthData.filter{$0.date > Date().addingTimeInterval(.month * 2)}[i - 1].date.get(.month) != value.date.get(.month) {
                           // withAnimation(.beat.delay(Double(i/2))) {
                                Spacer()
                            Text(formatter.string(from: value.date))
                                .font(.custom("Poppins", size: 10, relativeTo: .footnote))
                                .fixedSize()
                            
                               // .animation(.beat.delay(Double(i/30)), value: i)
                                //.padding()
                            
                            Spacer()
                        }
                        //}
                        //let date2 = Calendar.current.date(from: components)!
                        CalendarCell(i: i, op: 0, scale: 0, date: value.date, monthsData: $value, health: health)
                    }
                }
                }
//                        .onAppear() {
//                            self.i += 1
//                        }
                    }
            
//            CalendarView(health: health, interval: year) { date in
//                Button(String(self.calendar.component(.day, from: date))) {
//                    data = health.healthData.filter{$0.date.asDay() == date.asDay()}.first
//                }
//
//                    .frame(width: 40, height: 40, alignment: .center)
//                    .foregroundColor(Color.white)
//                    .background(content: {
//                        Group {
//                        if (health.healthData.filter{$0.date.asDay() == date.asDay()}.map{$0.risk}.filter{$0 == 1}.count ) > 0 {
//                            Color("red")
//                        } else if !(health.healthData.filter{$0.date.asDay() == date.asDay()}.isEmpty) {
//                            Color("green")
//                        } else {
//                            Color("back")
//                        }
//                        } .clipShape(RoundedRectangle(cornerRadius: 10))
//                    })
//
//                    .sheet(item: $data) { data in
//                        DataView(data2: data, health: health)
//                    }
//
//                    }
                  
                

                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        
            
        }
}


struct CalendarCell: View {
    @State var i: Int = 0
    @State var op: CGFloat = 0
    @State var scale: CGFloat = 0.5
    @State var date = Date()
    @Binding var monthsData: HealthData
    @State var isStrong = false
    @State var showData = false
    @Environment(\.calendar) var calendar
    private var year: DateInterval {
           calendar.dateInterval(of: .year, for: Date())!
       }
    @ObservedObject var health: Vito
    var body: some View {
        Button {
            showData = true
            
        } label: {
          
        ZStack {
            
            Text(String(monthsData.date.get(.day)))
                        .frame(width: 40, height: 40, alignment: .center)
                        //.foregroundColor(((monthsData.filter{$0.startDate.get(.day) == date.get(.day)}.last?.value ?? 0) > 2 ? Color.clear : Color.accentColor))
                        .font(.custom("Poppins", size: 12, relativeTo: .subheadline))
                        .foregroundColor(monthsData.risk == 1 ? Color.white : Color.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                              
                                .foregroundColor(monthsData.risk == 1 ? Color("red") : Color("green"))

                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            )
                       

                      //  .transition(.opacity.combined(with: .scale(scale: 1)))


        }
        }
    
        .opacity(op)
            .scaleEffect(scale)
            .padding()
            .onAppear() {
                withAnimation(.beat.delay(Double(i/25))) {
                    op = 1
                    scale = 1
                }
            }
            .sheet(isPresented: $showData) {
                DataView(data2: $monthsData, health: health)
            }
    }
    
}
