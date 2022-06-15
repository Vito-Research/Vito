////
////  DataView.swift
////  DataView
////
////  Created by Andreas on 8/18/21.
////
//
import SwiftUI
import HealthKit
import SwiftUICharts
import VitoKit

struct DataView: View {
   // @State var date = Date()
    @State var data2: HealthData
    
    @State var average = 0.0
    @State var min: CGFloat = 0.0
    @State var max: CGFloat = 0.0
    @ObservedObject var health: Vito
    //@State var data = ChartData(values: [("", 0.0)])
    @State var data: [(String, Double)] = [("",0.0)]
    
    @Environment(\.calendar) var calendar
   
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        NavigationView {
          //  ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        
                        Text("Average Heart Rate: " + String(round(data2.data * 10) / 10.0))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                        
                        Spacer()
       
                   
                    }

                    Spacer()
                    HStack {
                        Text("Heart Rate")
                            .font(.custom("Poppins-Bold", size: 24, relativeTo: .headline))
                        Spacer()
                    }
                    
                    Spacer()
                    VStack {
                        HStack {
                            Text("Heart Rate")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                      //  .padding(.top, 100)
                        HalvedCircularBar(data: data2, progress: $data2.risk, health: health, min: $min, max: $max, date: Date())
                        VStack {
                        HStack {
                            VStack {
                                
                                Text(String(data2.dataPoints.map{$0.value}.max() ?? 0))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(String(data2.dataPoints.map{$0.value}.min() ?? 0))
                                    .foregroundColor(.white)
                            }
                        BarChart()
                            .data(data)
                            .chartStyle(ChartStyle(backgroundColor: .clear, foregroundColor: [ColorGradient(.white)]))
                            .frame(maxWidth: .infinity, minHeight: 250)
                            .padding(.top)
                            
                        }
                            Text("Hour")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color("teal"))
                            .mask(RoundedRectangle(cornerRadius: 20))
                    } .onAppear() {
                        for b in data2.dataPoints.sliced(by: [.hour], for: \.date) {
                        
                            data.append((b.key.formatted(date: .omitted, time: .shortened), health.average(numbers: b.value.map{$0.value})))
                                
                            }
                                                       
                                                                                                               }
                                                       
                                                                                                               
                    
                    .padding()
                    
                    
                }
                  //  Spacer()
              //  }
                .padding()
                .navigationBarItems(trailing: Button (action: {
                    dismiss.callAsFunction()
                }, label: {
                    Text("Done")
                        .animation(nil)
                }))
                .navigationBarTitle("Details View")
            }
          
        }
           

    func lastDayOfMonth(date: Date) -> Date {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: date)?.end
      
           
        else { print("OOOF")
            return date }
        return monthInterval
    }
    func lastDayOfWeek(date: Date) -> Date {
        guard
        let monthInterval = calendar.dateInterval(of: .weekOfYear, for: date),
        let monthLastWeek = calendar.dateInterval(of: .weekday, for: monthInterval.end)?.end
           
        else { print("OOOF")
            return date }
        print(monthLastWeek)
        return monthLastWeek
    }
  
    func getDateRange(query: Query, date: Date) -> Bool {
        var isWithinTimePeriod = false
        let scaledDuration = query.durationType == .Week ? query.duration * 86400 * 7 : query.durationType == .Month ? query.duration  * 86400 * 30 : query.durationType == .Year ? query.duration  * 86400 * 365 : 86400 * query.duration
        let range = query.anchorDate.addingTimeInterval(-scaledDuration)...query.anchorDate
        if range.contains(date) {
            isWithinTimePeriod = true
        }
                return isWithinTimePeriod
                }

    }


