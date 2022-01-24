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
    @ObservedObject var health: HealthV2
    @State var data = ChartData(values: [("", 0.0)])
    
    @Environment(\.calendar) var calendar
   
    var body: some View {
        
        VStack {
            HStack {
                Text("Average Heart Rate: " + String(round(average * 10) / 10.0))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                Spacer()
//                DatePicker("", selection: $health.queryDate.anchorDate, displayedComponents: .date)
//                    .font(.custom("Poppins", size: 12, relativeTo: .headline))
//                .datePickerStyle(CompactDatePickerStyle())
//                .padding()
                .onAppear() {
                  //  health.queryDate.anchorDate = date
                    let points = getHeartRateData().filter{!$0.data.isNaN}
                    average = health.average(numbers: points.map{$0.data}.filter{!$0.isNaN})
                    data.points = points.map{($0.title, $0.data)}
                    

                }
            
            }
            HStack {
                Spacer()
//                TextField("Duration", value: $health.queryDate.duration, formatter: NumberFormatter())
//                    .keyboardType(.numberPad)
//                    .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
//                    .onChange(of: health.queryDate.duration) { value in
//
//                            let points = getHeartRateDataAsDoubleArr()
//                            average = health.average(numbers: points)
//                            data.points = points.map{("", $0)}
//                    }
                ForEach(DurationType.allCases, id: \.self) { value in
                    if value != .Year {
                    Button(action: {
                        withAnimation(.easeInOut) {
                        health.queryDate.durationType = value
                            let points = getHeartRateData().filter{!$0.data.isNaN}
                            average = health.average(numbers: points.map{$0.data}.filter{!$0.isNaN})
                            data.points = points.map{($0.title, $0.data)}
                            
                            print(data.points)
                        }
                    }) {
                        Text(value.rawValue)
                            .font(.custom("Poppins", size: 12, relativeTo: .subheadline))
                            .foregroundColor(value == health.queryDate.durationType ?  .white : .blue)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(value == health.queryDate.durationType ?  .blue : .white))
                            //.scaleEffect(value == health.queryDate.durationType ? 1.1 : 1)
                    }
                }
                }
               
            }
        
                //.opacity(isTutorial ? (tutorialNum == 1 ? 1.0 : 0.1) : 1.0)
            .onChange(of: health.queryDate.anchorDate, perform: { value in
            
                let points = getHeartRateData().filter{!$0.data.isNaN}
                
                average = health.average(numbers: points.map{$0.data}.filter{!$0.isNaN})
                data.points = points.map{($0.title, $0.data)}
                    
                  
                })
            if !health.risk.id.isEmpty {
                RiskCardView(health: health, date: health.queryDate.anchorDate, isCalendar: true)
                    .transition(.move(edge: .top))
            }
            HStack {
                Text("Heart Rate")
                    .font(.custom("Poppins-Bold", size: 24, relativeTo: .headline))
                Spacer()
            }  //.opacity(isTutorial ? (tutorialNum == 2 ? 1.0 : 0.1) : 1.0)
            
                
            BarChartView(data: $data, title: "Heart Rate")
               
           
            Spacer()
        } .padding()
           
        }
    
    func getHeartRateData() -> [HealthData] {
       
        return health.queryDate.durationType == .Month ? groupByDay(query: Query(id: UUID().uuidString, durationType: .Month, duration: 1, anchorDate: lastDayOfMonth(date: health.queryDate.anchorDate)), data: health.healthData.filter{$0.title == HKQuantityTypeIdentifier.heartRate.rawValue && getDateRange(query: Query(id: UUID().uuidString, durationType: .Month, duration: 1, anchorDate: lastDayOfMonth(date: health.queryDate.anchorDate)), date: $0.date) }) :  health.queryDate.durationType == .Week ? groupByWeek(query: health.queryDate, data: health.healthData.filter{$0.title == HKQuantityTypeIdentifier.heartRate.rawValue && getDateRange(query: Query(id: UUID().uuidString, durationType: .Week, duration: 1, anchorDate: lastDayOfWeek(date: health.queryDate.anchorDate)), date: $0.date)}) : groupByHour(query: Query(id: UUID().uuidString, durationType: .Day, duration: 1, anchorDate: health.queryDate.anchorDate), data: health.healthData.filter{$0.title == HKQuantityTypeIdentifier.heartRate.rawValue && getDateRange(query: health.queryDate, date: $0.date) }.map{HealthData(id: UUID().uuidString, type: .Health, title: "", text: "", date: $0.date, data: $0.data)})
    }
    func lastDayOfMonth(date: Date) -> Date {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: date)?.end
      //  let monthLastWeek = calendar.dateInterval(of: .day, for: monthInterval.end)?.end
           
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


