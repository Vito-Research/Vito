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
    @Published var healthStore = HKHealthStore()
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
    
    init() {
        if let earlyDate = Calendar.current.date(
            byAdding: .month,
            value: -6,
            to: Date()) {
            //Task {
                for date in Date.dates(from: Calendar.current.startOfDay(for: earlyDate), to: Date()) {
                    //print(date)
                    DispatchQueue.main.async {
                        //let sleep  = self.readSleep(from: Calendar.current.startOfDay(for: date), to:  Calendar.current.startOfDay(for: date).addingTimeInterval(86400))
                        print("SLEEP")
                        
                        
                    }
                  
                   // print(sleep.map{$0.date})
                    //DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                      
                    
                   
                   // }
                   
               // }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    let calendar = Calendar.current
                    let midnight = calendar.date(
                      bySettingHour: 0,
                      minute: 0,
                      second: 0,
                      of: date)!
                    let morning = calendar.date(
                      bySettingHour: 6,
                      minute: 0,
                      second: 0,
                      of: date)!
                    self.getHealthData(startDate: midnight, endDate: morning, i: 1)
                    self.getHealthData(startDate: midnight, endDate: morning, i: 0)
//                    }
                    var hrData2 = [HealthData]()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        print(self.hrData)
                        let noDates = self.hrData.filter{$0.data < 10 }.map{$0.date}
                        //self.hrData = self.hrData.filter{$0.date.getTimeOfDay() == "Night"}
                       // let grouped = self.groupByDay()
                       
//                        for group in grouped {
//                            print(group.first)
//                            hrData2.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: group.first?.date ?? Date(), data: self.average(numbers: group.map{$0.data})))
//                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        print(hrData2)
                            let filteredData = self.hrData.filter{!noDates.contains($0.date) && $0.title == HKQuantityTypeIdentifier.heartRate.rawValue }
                            let avgs = filteredData.map{$0.data}//self.getAvgPerNight(self.hrData)
                        let risks  = self.getRiskScore(filteredData, avgs: avgs)
                            
                            
                    print(risks)
                        }
                    }
                }
            } 
            
           
        }
        
    }
    func groupByDay() -> [[HealthData]] {
        guard !self.hrData.isEmpty else { return [] }
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
    func getRiskScore(_ health: [HealthData], avgs: [Double]) -> [Double] {
        var riskScores = [Double]()
        let medianOfAvg = calculateMedian(array: avgs)
        print(medianOfAvg)
        for avg in avgs {
            
            riskScores.append(avg >= Double(medianOfAvg) + 5.0 ? 1.0 : avg >= Double(medianOfAvg) + 4.0 ? 0.3 : 0.0)
        }
        return riskScores
    }
    func getAvgPerNight(_ health: [HealthData]) -> [Double] {
        var avgPerNight = [Double]()
        let health = health.filter {
            return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && !$0.data.isNaN //&& $0.date.getTimeOfDay() == "Night"
        }
        let dates =  health.map{$0.date}.sorted(by: { $0.compare($1) == .orderedDescending })
        if let startDate = dates.last      {
            
            
            if let endDate = dates.first {
                
                for date in Date.dates(from: startDate, to: endDate) {
                    
                    let todaysDate = health.filter{formatDate($0.date) == formatDate(date)}
                    
                    avgPerNight.append(average(numbers: todaysDate.map{$0.data}))
                    
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
}
