//
//  Healthv3.swift
//  Vito
//
//  Created by Andreas Ink on 1/31/22.
//

import SwiftUI
import Combine
import HealthKit

@MainActor
class Healthv3: ObservableObject {
    @UserDefault("codableRisk", defaultValue: [CodableRisk]())  var codableRisk: [CodableRisk]
    @UserDefault("medianOfAvgs", defaultValue: 0.0)  var medianOfAvgs: Double
    @UserDefault("avgs", defaultValue: [HealthData]())  var avgs: [HealthData]
    
    @Published var risk = Risk(id: UUID().uuidString, risk: 21, explanation: [Explanation(image: .return, explanation: "Loading", detail: "")])
    
    @Published var healthData = [HealthData]()
    @Published var riskData = [HealthData]()
    @Published var healthStore = HKHealthStore()
    
    var cancellableBag = Set<AnyCancellable>()
    let readData = [
            
          //  HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
       // HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
        
    ]
    
    let units: [HKUnit] = [HKUnit(from: "count/min"), HKUnit(from: "count")]
    let quanityTypes: [String] = ["Avg", "", ""]
    var hrData = [HealthData]()
    
    @Environment(\.calendar) var calendar
    let interval = DateInterval()
     var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
    init() {

       
    }
    func sync() {
                backgroundDelivery()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.getAvgPerNight(self.hrData)
        
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
        
                        let risks  = self.getRiskScore(self.hrData, avgs: self.avgs)
            print("RISK")
            print(risks)
                        if let lastRisk = risks.last?.risk {
                            let explanation =  lastRisk > 0.99 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your heart rate while asleep is abnormally high compared to your previous data", detail: ""), Explanation(image: .app, explanation: "This can be a sign of disease, intoxication, lack of sleep, or other factors.", detail: ""), Explanation(image: .stethoscope, explanation: "This is not medical advice or a diagnosis, it's simply a datapoint to bring up to your doctor", detail: "")] : [Explanation(image: .checkmark, explanation: "Your heart rate while asleep is normal compared to your previous data", detail: ""), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, it's simply a datapoint to bring up to your doctor", detail: "")]
                            self.risk = Risk(id: UUID().uuidString, risk: lastRisk, explanation: explanation)
                    }
                    }
                }
    }
    func readSleep(from startDate: Date?, to endDate: Date?, completionHandler: @escaping ([Date]) -> Void) {
        
       // let healthStore = HKHealthStore()
        var dates = [Date]()
        // first, we define the object type we want
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("OOOOOOF")
           
            fatalError()
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
                    
                completionHandler(result.map{$0.startDate})
            }
            
        }

        // finally, we execute our query
        healthStore.execute(query)
        
        
    }
    func calculateRisk() {
      //  DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            var noDates = [String]()
       noDates = self.hrData.filter{$0.data < 2 && $0.title == HKQuantityTypeIdentifier.stepCount.rawValue}.map{"\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))"}

      // print(self.hrData.map{$0.data})

        
        var filteredData = self.hrData.filter{!noDates.contains("\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))") && $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && $0.data < 200 && $0.data > 40}
        filteredData = filteredData.sliced(by: [.year, .month, .day], for: \.date).map{ HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: $0.key, data: self.average(numbers: $0.value.map{$0.data}))}
        filteredData =  filteredData.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        // print(filteredData.map{$0.date})
        self.healthData = filteredData
            self.getAvgPerNight(filteredData)
                
            
               
//            }
//
//        }
    }
    func backgroundDelivery() {
        
        if let earlyDate = Calendar.current.date(
            byAdding: .month,
            value: -3,
            to: Date()) {
                for date in Date.dates(from: Calendar.current.startOfDay(for: earlyDate), to: Date()) {
                    if let earlyDate = Calendar.current.date(
                        byAdding: .day,
                        value: -1,
                        to: date) {
                       // Task {
                             readSleep(from: earlyDate, to: date) { datesSleepArr in
                                
                            
                        print("DATES HERE")
                        print(datesSleepArr)
                        if let startDate = datesSleepArr.min() {
                            if let endDate = datesSleepArr.filter({($0) < (datesSleepArr.min() ?? Date()).addingTimeInterval(36000)}).max() {
                                print("DATES")
                                print(startDate)
                                print(endDate)
                         
                                let calendar = Calendar.current
                   
                                for hour in Date.dates(from: startDate.addingTimeInterval(-3600), to: endDate.addingTimeInterval(3600)).map({$0.get(.hour)}) {
                        
                        let midnight = calendar.date(
                            bySettingHour: hour,
                          minute: 0,
                          second: 0,
                          of: date)!
                       
                        let morning = calendar.date(
                            bySettingHour: hour,
                          minute: 59,
                          second: 0,
                          of: date)!
                                    self.getHealthData(startDate: midnight, endDate: morning, i: 1) { stepData in
                                        self.healthData.append(stepData)
                                        
                                    self.getHealthData(startDate: midnight, endDate: morning, i: 0) { hrData in
                                        self.hrData.append(hrData)
                                        
                                    }
                                        
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    var noDates = self.healthData.filter{$0.data < 2 && $0.title == HKQuantityTypeIdentifier.stepCount.rawValue}.map{"\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))"}
                                        
                                        self.hrData = self.hrData.filter{!noDates.contains("\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))") && $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && $0.data < 200}
                                    }
                                }
                            }
                        }
                                
                                 //                for i in filteredData.indices {
//
//
//                    for risk in risks {
//                        self.codableRisk.append(CodableRisk(id: UUID().uuidString, date: risk.date, risk: risk.data, explanation: []))
//                    }
//
//            }
                                
                                    }
                             }
                    
                    
                }
          
        }
    }
    
    
    func getHealthData(startDate: Date, endDate: Date, i: Int, completionHandler: @escaping (HealthData) -> Void) {
        var healthData: HealthData?
       
        healthStore
            .statistic(for: Array(readData)[i], with: self.quanityTypes[i] == "Avg" ? .discreteAverage : .cumulativeSum, from: startDate, to: endDate, 1000)
            .receive(on: DispatchQueue.main)
        
            .sink(receiveCompletion: { subscription in
         
            }, receiveValue: { stat in
               //print(stat.averageQuantity()?.doubleValue(for: self.units[i]))
                // If there's smaples then add the sample to healthData
                 if let quanity = self.quanityTypes[i] == "Avg" ? stat.averageQuantity()?.doubleValue(for: self.units[i]) : stat.sumQuantity()?.doubleValue(for: self.units[i]) {
                     if !quanity.isNaN {
                        
                         completionHandler(HealthData(id: "\(i)", type: DataType(rawValue: Array(self.readData)[i].identifier) ?? .Health, title: Array(self.readData)[i].identifier, text: Array(self.readData)[i].identifier, date: stat.startDate, data: quanity))
                         
                     }
                     
                }
               
            // Does something, lol
            }).store(in: &cancellableBag)
       
        //throw Errors.noValue
    }
    enum Errors: Error {
        case noValue
        
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
    
    func getRiskScore(_ health: [HealthData], avgs: [HealthData]) -> [HealthData] {
        var riskScores = [HealthData]()
        let medianOfAvg = calculateMedian(array: avgs.map{$0.data})
       // print(medianOfAvg)
        var lastAvg = 0.0
        var alertLvl = 0
        for avg in avgs {
            switch(alertLvl) {
            case 0:
                if avg.data >= (Double(medianOfAvg) + 4.0)  {
                    alertLvl = 2
                } else if avg.data >= (Double(medianOfAvg) + 3.0) {
                    alertLvl = 1
                }
            case 1:
                if avg.data >= (Double(medianOfAvg) + 4.0)  {
                    alertLvl = 4
                } else if avg.data >= (Double(medianOfAvg) + 3.0) {
                    alertLvl = 3
                } else if avg.data < (Double(medianOfAvg) + 3.0)  {
                    alertLvl = 0
                }
            case 2:
                if avg.data >= (Double(medianOfAvg) + 4.0)  {
                    alertLvl = 5
                }  else if avg.data >= (Double(medianOfAvg) + 3.0) {
                    alertLvl = 3
                } else if avg.data < (Double(medianOfAvg) + 3.0)  {
                     alertLvl = 0
                }
            case 3:
                if avg.data >= (Double(medianOfAvg) + 4.0)  {
                    alertLvl = 4
                }  else if avg.data >= (Double(medianOfAvg) + 3.0) {
                    alertLvl = 3
                } else if avg.data < (Double(medianOfAvg) + 3.0) {
                    alertLvl = 0
                }
            case 4:
                if avg.data >= (Double(medianOfAvg) + 4.0)  {
                    alertLvl = 5
                } else if avg.data < (Double(medianOfAvg) + 3.0)  {
                    alertLvl = 0
                }
            case 5:
                if avg.data >= (Double(medianOfAvg) + 4.0)  {
                    alertLvl = 5
                } else if avg.data < (Double(medianOfAvg) + 3.0) {
                    alertLvl = 0
                } else {
                    alertLvl = 3
                }
            default:
            break
            }
            riskScores.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: avg.date, data: avg.data, risk: alertLvl > 3 ? 1 : 0))
            // riskScores.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: avg.date, data: avg.data, risk: avg.data >= Double(medianOfAvg) + 4.0 && lastAvg > Double(medianOfAvg) + 4.0 || (avg.data >= Double(medianOfAvg) + 3.0 && lastAvg >= Double(medianOfAvg) + 3.0) ? 1.0 : 0.0))
            
            print(avg)
            lastAvg = avg.data
        }
        return riskScores
    }
    func getAvgPerNight(_ health: [HealthData])  {//-> [HealthData]  {
        //var avgPerNight = [HealthData]()
        self.avgs = []
        let health = health.filter {
            return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && !$0.data.isNaN  && $0.data < 200 && $0.data > 40
        }
        
        let dates =  health.map{$0.date}.sorted(by: { $0.compare($1) == .orderedDescending })
        if let startDate = dates.last {
            
            
            if let endDate = dates.first {
                
                for date in Date.dates(from: startDate, to: endDate) {
                    
                    let todaysDate = health.filter{$0.date.get(.day) == date.get(.day) && $0.date.get(.month) == date.get(.month) }
                    let avg = average(numbers: todaysDate.map{$0.data})
                    if  !avg.isNaN {
                    avgs.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: date, data: avg))
                        
                    } else {
                        if let first = todaysDate.map({$0.data}).first {
                            avgs.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: date, data: first))
                        }
                    }
                }
            }
           
        }
        //print(avgPerNight)
            // return avgPerNight
    }
    
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
