//
//  HealthV2.swift
//  Vito
//
//  Created by Andreas Ink on 1/19/22.
//

import SwiftUI
import HealthKit
import Combine

class HealthV2: ObservableObject {
    
    @State var onboarding = UserDefaults.standard.bool(forKey: "onboarding")
    @State var medianOfAverages = UserDefaults.standard.double(forKey: "medianOfAverages")
    @Published var tempHealthData = HealthData(id: UUID().uuidString, type: .Feeling, title: "", text: "", date: Date(), data: 0.0)
    @Published var healthStore = HKHealthStore()
    @Published var risks = [Double]()
    @Published var queryDate = Query(id: "", durationType: .Day, duration: 1, anchorDate: Date())
    @Published var codableRisk = [CodableRisk(id: "NoData", date: Date().addingTimeInterval(-1000000000000), risk: 0.0, explanation: [String]())]
    @Published var risk = Risk(id: "NoData", risk: 21, explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Explain it here!!", detail: ""), Explanation(image: .questionmarkCircle, explanation: "Explain it here?", detail: ""), Explanation(image: .circle, explanation: "Explain it here.", detail: "")])
    @Published var healthChartData = ChartData(values: [("", 0.0)])
     var healthData = [HealthData]()
    var hrData = [HealthData]()
    var cancellableBag = Set<AnyCancellable>()
    let readData = [
            
          //  HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
       // HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
        
    ]
    
    let units: [HKUnit] = [HKUnit(from: "count/min"), HKUnit(from: "count")]
    let quanityTypes: [String] = ["Avg", "", ""]
    
    @Environment(\.calendar) var calendar
    let interval = DateInterval()
     var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
    init() {
        backgroundDelivery()
    }
    func groupByMonth() -> [[HealthData]] {
        guard !self.hrData.isEmpty else { return [] }
        let dictionaryByMonth = Dictionary(grouping: self.healthData, by: { $0.date.get(.month) })
      let months = Array(1...12) // rotate this array if you want to go from October to September
      return months.compactMap({ dictionaryByMonth[$0] })
    }
    func groupByDay(_ healthData: [HealthData]) -> [[HealthData]] {
        guard !healthData.isEmpty else { return [] }
        let dictionaryByMonth = Dictionary(grouping: self.healthData, by: { $0.date.get(.day) })
      let months = Array(1...30) // rotate this array if you want to go from October to September
      return months.compactMap({ dictionaryByMonth[$0] })
    }
    func getStartEndOfSleep(_ healthData: [HealthData]) -> [Date] {
        let dates = healthData.map{$0.date} + healthData.map{$0.text.toDate() ?? Date()}
        return [dates.min() ?? Date(), dates.max() ?? Date()]
        
    }
    func readSleep(from startDate: Date?, to endDate: Date?) -> [HealthData] {
        
       // let healthStore = HKHealthStore()
        var healthData = [HealthData]()
        // first, we define the object type we want
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("OOOOOOF")
            return []
        }
        
        // we create a predicate to filter our data
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])

        // I had a sortDescriptor to get the recent data first
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        // we create our query with a block completion to execute
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) { [self] (query, result, error) in
            if error != nil {
                // handle error
                //return
            }
            
            if let result = result {
                
                // do something with those data
                result
                    .compactMap({ $0 as? HKCategorySample })
                    .forEach({ sample in
                        guard let sleepValue = HKCategoryValueSleepAnalysis(rawValue: sample.value) else {
                            return
                        }
                        
                        let isAsleep = sleepValue == .asleep
                        
                        //print("HealthKit sleep \(sample.startDate) \(sample.endDate) - source \(sample.sourceRevision.source.name) - isAsleep \(isAsleep)")
                        
                        self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: "", text:  sample.endDate.getFormattedDate(format: "yyyy-MM-dd HH:mm:ss"), date: sample.startDate, data: (sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue) ? 1 : 0))
                        
                      
                        
                    })
            }
            
        }

        // finally, we execute our query
        healthStore.execute(query)
        return healthData
        
    }
    func getHealthData(startDate: Date, endDate: Date, i: Int) {

        healthStore
            .statistic(for: Array(readData)[i], with: self.quanityTypes[i] == "Avg" ? .discreteAverage : .cumulativeSum, from: startDate, to: endDate, 1000)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { subscription in
         
            }, receiveValue: { stat in
               //print(stat.averageQuantity()?.doubleValue(for: self.units[i]))
                // If there's smaples then add the sample to healthData
                 if let quanity = self.quanityTypes[i] == "Avg" ? stat.averageQuantity()?.doubleValue(for: self.units[i]) : stat.sumQuantity()?.doubleValue(for: self.units[i]) {
                     if !quanity.isNaN {
                         self.hrData.append(HealthData(id: "\(i)", type: DataType(rawValue: Array(self.readData)[i].identifier) ?? .Health, title: Array(self.readData)[i].identifier, text: Array(self.readData)[i].identifier, date: stat.startDate, data: quanity))
                         
                         
                     }
                     
                }
            // Does something, lol
            }).store(in: &cancellableBag)
        //return true
    }
    func getRiskScore(_ health: [HealthData], avgs: [HealthData]) -> [Double] {
        var riskScores = [Double]()
        let medianOfAvg = calculateMedian(array: avgs.map{$0.data})
        print(medianOfAvg)
        for avg in avgs {
            
            riskScores.append(avg.data >= Double(medianOfAvg) + 4.0 ? 1.0 : avg.data >= Double(medianOfAvg) + 3.0 ? 0.3 : 0.0)
        }
        return riskScores
    }
    func getAvgPerNight(_ health: [HealthData]) -> [HealthData] {
        var avgPerNight = [HealthData]()
        
        let health = health.filter {
            return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && !$0.data.isNaN //&& $0.date.getTimeOfDay() == "Night"
        }
        
        let dates =  health.map{$0.date}.sorted(by: { $0.compare($1) == .orderedDescending })
        if let startDate = dates.last      {
            
            
            if let endDate = dates.first {
                
                for date in Date.dates(from: startDate, to: endDate) {
                    
                    let todaysDate = health.filter{formatDate($0.date) == formatDate(date)}
                    
                    avgPerNight.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: date, data: average(numbers: todaysDate.map{$0.data})))
                    
                }
            }
            
        }
        print(avgPerNight)
        return avgPerNight
    }
    
    func calculateMedian(array: [Double]) -> Float {
        let sorted = array.sorted().filter{!$0.isNaN}
        if !sorted.isEmpty {
        if sorted.count % 2 == 0 {
                return Float((sorted[(sorted.count / 2)] + sorted[(sorted.count / 2) - 1])) / 2
            } else {
                return Float(sorted[(sorted.count - 1) / 2])
            }
        }
        return 21.0
    }
   // Gets average of input and outputs
    func average(numbers: [Double]) -> Double {
       // print(numbers)
       return Double(numbers.reduce(0,+))/Double(numbers.count)
   }
    func formatDate(_ startDate: Date) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        return dateFormatterGet.string(from: startDate) //{
        //            return dateFormatterPrint.string(from: date)
        
        
    }
    
    func formatDate(_ startDate: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        if let date = dateFormatterGet.date(from: startDate) {
            return dateFormatterPrint.string(from: date)
            
        } else {
            print("There was an error decoding the string")
        }
        return ""
    }
    func backgroundDelivery() {
        var hrData2 = [HealthData]()
        DispatchQueue.main.async {
            
            
            self.healthStore.requestAuthorization(toShare: [], read: Set(self.readData)) { (success, error) in
            self.healthStore.requestAuthorization(toShare: [], read:  Set([HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])) { (success, error) in
                
                if success {
        let readType2 = HKObjectType.quantityType(forIdentifier: .heartRate)
      
            if let readType2 = readType2 {
                //if self.healthStore.authorizationStatus(for: readType2) == .sharingAuthorized {
                self.healthStore.enableBackgroundDelivery(for: readType2, frequency: .daily) { success, error in
            if !success {
                print("Error enabling background delivery for type \(readType2.identifier): \(error.debugDescription)")
            } else {
                print("Success enabling background delivery for type \(readType2.identifier)")
                var noDates = [String]()
                if let earlyDate = Calendar.current.date(
                    byAdding: .month,
                    value: -3,
                    to: Date()) {
                    //Task {
                        for date in Date.dates(from: Calendar.current.startOfDay(for: earlyDate), to: Date()) {
                            //print(date)
        //                    DispatchQueue.main.async {
        //                        //let sleep  = self.readSleep(from: Calendar.current.startOfDay(for: date), to:  Calendar.current.startOfDay(for: date).addingTimeInterval(86400))
        //                        print("SLEEP")
        //
        //
        //                    }
                          
                           // print(sleep.map{$0.date})
                            //DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                              
                            
                           
                           // }
                           
                       // }
                        //DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            let calendar = Calendar.current
                           
                            for hour in 0...4 {
                                
                                let midnight = calendar.date(
                                  bySettingHour: hour,
                                  minute: 0,
                                  second: 0,
                                  of: date)!
                                #warning("expand")
                                let morning = calendar.date(
                                  bySettingHour: hour ,
                                  minute: 59,
                                  second: 0,
                                  of: date)!
                                
                            self.getHealthData(startDate: midnight, endDate: morning, i: 1)
                            self.getHealthData(startDate: midnight, endDate: morning, i: 0)
        //                    }
                           
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                               // print(self.hrData)
                                noDates = self.hrData.filter{$0.data < 2 && $0.title == HKQuantityTypeIdentifier.stepCount.rawValue}.map{"\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))"}
                                
                                print(self.hrData.map{$0.data})
                                //self.hrData = self.hrData.filter{$0.date.getTimeOfDay() == "Night"}
                                //let grouped = self.groupByMonth()
                                
//                               var monthlyGrouped = [HealthData]()
//                                for group in grouped {
//                                    print(group)
//                                    hrData2.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: group.first?.date ?? Date(), data: self.average(numbers: group.map{$0.data})))
//                                }
                                
//                                let grouped2 = self.groupByDay(monthlyGrouped)
//
//                                for group in grouped2 {
//                                    print(group.first)
//                                    hrData2.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: group.first?.date ?? Date(), data: self.average(numbers: group.map{$0.data})))
//                                }
                               // DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                
                                  
                                    
                            
                                }
                            //}
                       // }
                            }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        
                        //print(self.hrData.sliced(by: [.year, .month, .day], for: \.date).keys)
                       
                        var filteredData = self.hrData.filter{!noDates.contains("\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))") && $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && $0.data < 200}
                        filteredData = filteredData.sliced(by: [.year, .month, .day], for: \.date).map{ HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: $0.key, data: self.average(numbers: $0.value.map{$0.data}))}
                        print(filteredData.map{$0.date})
                    let avgs = self.getAvgPerNight(filteredData)
                let risks  = self.getRiskScore(filteredData, avgs: avgs)
                        print(risks)
                        
                        let riskScore = self.average(numbers: Array(risks.dropFirst(risks.count - 2)))
                    if riskScore == 1 {
                        print("ALERT")
                       
                    }
                        let explanation =  riskScore > 0.99 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your heart rate while asleep is abnormally high compared to your previous data", detail: ""), Explanation(image: .app, explanation: "This can be a sign of disease, intoxication, lack of sleep, or other factors.", detail: ""), Explanation(image: .stethoscope, explanation: "This is not medical advice or a diagnosis, it's simply a datapoint to bring up to your doctor", detail: "")] : [Explanation(image: .checkmark, explanation: "Your heart rate while asleep is normal compared to your previous data", detail: ""), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, it's simply a datapoint to bring up to your doctor", detail: "")]
                        
                        self.codableRisk.append(CodableRisk(id: UUID().uuidString, date: Date(), risk: riskScore, explanation: []))
                        self.risk = Risk(id: UUID().uuidString, risk: riskScore, explanation: explanation)
                    }
                }
                
                    }
            }
                }
        }
            }
            }
            
        }
    }
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    func convertHealthDataToChart(healthData: [HealthData], completionHandler: @escaping (ChartData) -> Void) {
        
        for data in healthData {
            healthChartData.points.append((data.type.rawValue,  data.data*10))
            
        }
        completionHandler(healthChartData)
    }
}
