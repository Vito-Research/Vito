////
////  DataView.swift
////  DataView
////
////  Created by Andreas on 8/18/21.
////
//
import SwiftUI
import HealthKit
struct DataView: View {
    @State private var date = Date()
    @State private var average = 0.0
    @ObservedObject var health: Healthv3
    @State var data = ChartData(values: [("", 0.0)])
    
    @Environment(\.calendar) var calendar
   
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text("Average Heart Rate: " + String(round(average * 10) / 10.0))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                        Spacer()
       
                        .onAppear() {
                         
                            let points = getHeartRateData().filter{!$0.data.isNaN}
                            if points.count < 1 {
                                average = points.first?.data ?? 0
                                data.points = points.map{($0.title, $0.data)}
                            } else {
                            average = health.average(numbers: points.map{$0.data}.filter{!$0.isNaN})
                            data.points = points.map{("\($0.date.get(.hour))", $0.data)}
                            }

                        }
                    
                    }
                    HStack {
                        Spacer()
       
                        ForEach(DurationType.allCases, id: \.self) { value in
                            if value != .Year {
                            Button(action: {
                                withAnimation(.easeInOut) {
                                health.queryDate.durationType = value
                                    let points = getHeartRateData()
                                    average = health.average(numbers: points.map{$0.data}.filter{$0.isNormal})
                                    data.points = points.map{("\($0.date.get(.hour))", $0.data)}
                                    
                                    print(data.points)
                                }
                            }) {
                                Text(value.rawValue)
                                    .font(.custom("Poppins", size: 12, relativeTo: .subheadline))
                                    .foregroundColor(value == health.queryDate.durationType ?  .white : .blue)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(value == health.queryDate.durationType ?  .blue : .white))
                                   
                            }
                        }
                        }
                       
                    }
                
                    .onChange(of: health.queryDate.anchorDate, perform: { value in
                    
                        let points = getHeartRateData().filter{!$0.data.isNaN}
                        
                        average = health.average(numbers: points.map{$0.data}.filter{!$0.isNaN})
                        data.points = points.map{("\($0.date.get(.hour))", $0.data)}
                      
                          
                        })
                    if !health.risk.id.isEmpty {
                        RiskCardView(health: health, date: health.queryDate.anchorDate, isCalendar: true)
                            .transition(.move(edge: .top))
                    }
                    HStack {
                        Text("Heart Rate")
                            .font(.custom("Poppins-Bold", size: 24, relativeTo: .headline))
                        Spacer()
                    }
                    
                        
                    BarChartView(data: $data, title: "Heart Rate")
                       
                   
                    Spacer()
                } .padding()
            }
            .navigationBarItems(trailing: Button (action: {
                dismiss.callAsFunction()
            }, label: {
                Text("Done")
            }))
            .navigationBarTitle("Data View")
        }
           
        }

    func getHeartRateData() -> [HealthData] {

        let components = Calendar.current.dateComponents(health.queryDate.durationType == .Month ? [.month, .year] : health.queryDate.durationType == .Week ? [.weekOfMonth, .month, .year] : [.day, .month, .year], from: health.queryDate.anchorDate)
        let date = Calendar.current.date(from: components)!

       
        return (health.queryDate.durationType == .Month ? health.hrData.sliced(by: [.month, .year], for: \.date)[date] : health.queryDate.durationType == .Week ? health.hrData.sliced(by: [.weekOfMonth, .month, .year], for: \.date)[date] : health.hrData.sliced(by: [.day, .month, .year], for: \.date)[date]) ?? [HealthData]()

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
    func groupByDay(query: Query, data: [HealthData]) -> [HealthData] {
        
        var healthData =  [HealthData]()
        for month in health.months {
            
            for day in  0...32 {
            // Filter to day and to month that's not today
            let filteredToDay = data.filter {
                return $0.date.get(.day) == day &&  $0.date.get(.month) == month.get(.month)
            }
                let filteredTo = query.durationType == .Week ? filteredToDay.filter{$0.date.get(.weekOfYear) == query.anchorDate.get(.weekOfYear)}.filter{!$0.data.isNaN}.map{$0.data} : filteredToDay.filter{!$0.data.isNaN}.map{$0.data}
            // Get average for that day
                healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: DateFormatter.localizedString(from: (filteredToDay.last?.date ?? Date()), dateStyle: .short, timeStyle: .none), text: "", date: month, data: health.average(numbers: filteredTo)))
          
        }
        }
            return healthData
        
        
    }
    func groupByHour(query: Query, data: [HealthData]) -> [HealthData] {
        
        var healthData =  [HealthData]()
        for month in health.months {
            if month.get(.month) == query.anchorDate.get(.month) {
            for day in  0...24 {
            // Filter to day and to month that's not today
            let filteredToDay = data.filter {
                return $0.date.get(.hour) == day &&  $0.date.get(.month) == month.get(.month) &&  $0.date.get(.weekday) == query.anchorDate.get(.weekday)  &&  $0.date.get(.weekOfYear) == query.anchorDate.get(.weekOfYear)
            }
                let filteredTo = filteredToDay.map{$0.data}
            // Get average for that day
                healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: DateFormatter.localizedString(from: (filteredToDay.last?.date ?? Date()), dateStyle: .none, timeStyle: .short), text: "", date: month, data: health.average(numbers: filteredTo)))
          
        }
            }
        }
            return healthData
        
        
    }
    func groupByWeek(query: Query, data: [HealthData]) -> [HealthData] {
        
        var healthData =  [HealthData]()
        for month in health.months {
            if month.get(.month) == query.anchorDate.get(.month) {
            for day in  0...7 {
            // Filter to day and to month that's not today
            let filteredToDay = data.filter {
                return $0.date.get(.weekday) == day &&  $0.date.get(.month) == month.get(.month) &&  $0.date.get(.weekOfYear) == query.anchorDate.get(.weekOfYear)
            }
                let filteredTo = filteredToDay.filter{$0.date.get(.weekOfYear) == query.anchorDate.get(.weekOfYear)}.filter{!$0.data.isNaN}.map{$0.data}
            // Get average for that day
                healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: "\(DayOfWeek(rawValue: day) ?? .Monday)", text: "", date: month, data: health.average(numbers: filteredTo)))
          
        }
            }
        }
            return healthData
        
        
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
    func loadData( completionHandler: @escaping (String) -> Void) {
       
        data = ChartData(values: [("", 0.0)])
        
        
        let filtered = health.codableRisk.filter { data in
            return data.date.get(.weekOfYear) == date.get(.weekOfYear) && date.get(.year) == data.date.get(.year)
        }
        print(filtered)
        let scorePoints = ChartData(values: [("", 0.0)])
        
        for day in 0...7 {
            
       
            let filteredDay = filtered.filter { data in
               
                return data.date.get(.weekday) == day
            }
            
            
            let averageScore =  health.average(numbers: filteredDay.map{$0.risk})
           
            scorePoints.points.append(("\(DayOfWeek(rawValue: day) ?? .Monday)", averageScore))
            
            
           
           
 
            self.data = scorePoints
        
        }
    }
    }


