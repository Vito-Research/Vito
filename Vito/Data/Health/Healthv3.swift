//
//  Healthv3.swift
//  Vito
//
//  Created by Andreas Ink on 1/31/22.
//


import SwiftUI
import Combine
import HealthKit
import HKCombine
import Accelerate

// Makes class stay on main thread
@MainActor
class Healthv3: ObservableObject {
    
    // @UserDefault saves the data locally
    // Saves all risk scores locally
    @UserDefault("codableRisk", defaultValue: [CodableRisk]())  var codableRisk: [CodableRisk]
    
    // Saves median of averages to skip data query
    @UserDefault("medianOfAvgs", defaultValue: 0.0)  var medianOfAvgs: Double
    

    
    @UserDefault("uses2", defaultValue: 0)  var uses2: Int
    
    @UserDefault("usingFitbit", defaultValue: false)  var usingFitbit: Bool
    
    // Stores avg hr per night
    @UserDefault("avgs", defaultValue: [HealthData]())  var avgs: [HealthData]
    
    // Current night's risk
    @Published var risk = Risk(id: UUID().uuidString, risk: 21, explanation: [Explanation(image: .return, explanation: "Loading", detail: "")])
    
    // Used for DataView to select a date
    @Published var queryDate = Query(id: "", durationType: .Day, duration: 1, anchorDate: Date())
    
    // Stores healthdata
    @UserDefault("healthData", defaultValue: [HealthData]())  var healthData
    
    // Stores risk data
    @UserDefault("riskData", defaultValue: [HealthData]()) var riskData
    
    // Class to retrieve health data
    @Published var healthStore = HKHealthStore()
    
    // Combine tool, a protocol indicating that an activity or action supports cancellation.
    var cancellableBag = Set<AnyCancellable>()
    
    // The health data read
    let readData: Set<HKSampleType> = [
        
        
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
    ]
    let readData2 = [
        
        
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        
       
        
    ]
    
    // The units of the readData
    let units: [HKUnit] = [HKUnit(from: "count/min"), HKUnit(from: "ms"), HKUnit(from: "count"), HKUnit(from: "count/min")]
    
    // The quanity types of the readData
    let quanityTypes: [String] = ["Avg", "", "Avg"]
    
    // HR data only
    var hrData = [HealthData]()
    
    // Initiates calendar
    @Environment(\.calendar) var calendar
    
    // Used for codde below
    let interval = DateInterval()
    
    // Generates months
    var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
    
    @State var fitbitData: [Date: FitbitData?] = [:]
    
    @Published var progress: CGFloat = 0.0
    
    var alertLvl = AlertLevelv3()
    
    init() {

        self.processData()

    }
    func processData() {
        if usingFitbit {
            print(fitbitData)
            for fitbitData in fitbitData {
                if let hr = fitbitData.value {
                do {
                    
                    for data in hr.activitiesHeart {
                        print(data)
                        
                            if let restingHR = data.value.restingHeartRate {
                                var newData = HealthData(id: UUID().uuidString, type: .Health, title: "Fitbit", text: "Fitbit", date: fitbitData.key, data: Double(restingHR))

                            newData.risk = self.alertLvl.calculateMedian(Int(newData.data), newData.date, yellowThres: 3, redThres: 4)
                            self.riskData.append(newData)
                            self.hrData.append(newData)
                    }
                    }
                    
                } catch {
                }
            } else {
            }
            }

                    
               
        } else {
            backgroundDelivery()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 60 * 3) {
        if let lastRisk = self.riskData.last?.risk {
            let explanation =  lastRisk > 0 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your heart rate while asleep is abnormally high compared to your previous data", detail: ""), Explanation(image: .app, explanation: "This can be a sign of disease, intoxication, lack of sleep, or other factors", detail: ""), Explanation(image: .stethoscope, explanation: "This is not medical advice or a diagnosis, it's simply a datapoint to bring up to your doctor", detail: "")] : [Explanation(image: .checkmark, explanation: "Your heart rate while asleep is normal compared to your previous data", detail: ""), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, it's simply a datapoint to bring up to your doctor", detail: "")]
            self.risk = Risk(id: UUID().uuidString, risk: lastRisk, explanation: explanation)
            
            if lastRisk == 1 {
                let content = UNMutableNotificationContent()
                content.title = "Change in Physiological Pattern"
                content.subtitle = "Your health data may indicate a stress event"
                content.sound = UNNotificationSound.default

                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)

            }
        }
        }
    }
    

   
   
    func backgroundDelivery() {
        
        self.healthStore.requestAuthorization(toShare: [], read: self.readData) { (success, error) in
        if let rr =  HKObjectType.quantityType(forIdentifier: .respiratoryRate) {
            self.healthStore.enableBackgroundDelivery(for: rr, frequency: .daily) { [self] sucess, error in
                if let max = riskData.map({$0.date}).max() {
                 let distance = max.distance(to: Date())
                    print(distance)

                Task {
                    
                    for day in Date.dates(from: Date().addingTimeInterval(-distance), to: Date()) {
                  print(day)
                    
                do {
                    let hv4 = Healthv4()
                    if var newData = try await hv4.loadNewDataFromHealthKit(type: HKObjectType.quantityType(forIdentifier: .heartRate)!, unit: HKUnit(from: "count/min"), start: day, end: day.addingTimeInterval(86400)) {
                        if newData.data.isNormal {
  
                            newData.risk = self.alertLvl.calculateMedian(Int(newData.data), newData.date, yellowThres: 3, redThres: 4)
                            self.riskData.append(newData)
                            self.hrData.append(newData)
                            
                        } else {
                            
                        }
                    }
                    
                } catch {
                }
                        progress = (day.timeIntervalSince1970/distance) * 10
                }
                }
                
                    
                } else {
                    if let earlyDate = Calendar.current.date(
                                  byAdding: .month,
                                  value: -12,
                                  to: Date()) {
                    Task {
                        let distance = earlyDate.distance(to: Date())
                        for day in Date.dates(from: earlyDate, to: Date()) {
                      print(day)
                        
                    do {
                        let hv4 = Healthv4()
                        if var newData = try await hv4.loadNewDataFromHealthKit(type: HKObjectType.quantityType(forIdentifier: .heartRate)!, unit: HKUnit(from: "count/min"), start: day, end: day.addingTimeInterval(86400)) {
                            if newData.data.isNormal {
    
                                newData.risk = self.alertLvl.calculateMedian(Int(newData.data), newData.date, yellowThres: 3, redThres: 4)
                                self.riskData.append(newData)
                                self.hrData.append(newData)
                            } else {
                                
                            }
                        }
    
                    
                                
         
                        
                    } catch {
                    }
                        
                            progress = (day.timeIntervalSince1970/distance) * 10
                        }
                    }
                    }
        }
            }
        }
    }
    }
    func retrieveSleepAnalysis(time: Int) {
           print("YE")
           // first, we define the object type we want
           if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
               
               // Use a sortDescriptor to get the recent data first
               let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
               
               // we create our query with a block completion to execute
              
               let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: time, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                   
                   if error != nil {
                       
                       // something happened
                       return
                       
                   }
                   
                   if let result = tmpResult {
                       
                       // do something with my data
                       for item in result {
                           if let sample = item as? HKCategorySample {
                              
                               print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(sample.value)")
                               
                               //if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue || sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue  {
                               self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: "", text:  sample.endDate.getFormattedDate(format: "yyyy-MM-dd HH:mm:ss"), date: sample.startDate, data: (sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue) ? 1 : 0))
                           //    }
                               //(sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue)
                           }
                       }
                   }
               }
               
               // finally, we execute our query
               healthStore.execute(query)
           }
       }
    
    
    func getHealthData(startDate: Date, endDate: Date, i: Int, completionHandler: @escaping (HealthData?) -> Void) {
        
        healthStore
        
        // Stat = average in a time period or total amount in a time period
            .statistic(for: Array(readData2)[i], with: self.quanityTypes[i] == "Avg" ? .discreteAverage : .cumulativeSum, from: startDate, to: endDate, 10)
        
            .receive(on: DispatchQueue.main)
            
            .sink(receiveCompletion: { subscription in
                // If error (no stats) then return nil
                if "\(subscription)".contains("failure") {
                    completionHandler(nil)
                }
                
            }, receiveValue: { stat in
                
               
                // If there's smaples then add the sample to healthData
                if let quanity = self.quanityTypes[i] == "Avg" ? stat.averageQuantity()?.doubleValue(for: self.units[i]) : stat.sumQuantity()?.doubleValue(for: self.units[i]) {
                    if !quanity.isNaN {
                        
                        // Return the health data
                        completionHandler(HealthData(id: "\(i)", type: DataType(rawValue: Array(self.readData)[i].identifier) ?? .Health, title: Array(self.readData)[i].identifier, text: Array(self.readData)[i].identifier, date: stat.startDate, endDate: stat.endDate, data: quanity))
                        
                    } else {
                        completionHandler(nil)
                    }
                    
                } else {
                    completionHandler(nil)
                }
                
               
            }
                  
                  
            ).store(in: &cancellableBag)
        
        
        
    }
 // Calculates median
    func calculateMedian(array: [Double]) -> Float? {
        let sorted = array.sorted().filter{!$0.isNaN}
        if !sorted.isEmpty {
            if sorted.count % 2 == 0 {
                return Float((sorted[(sorted.count / 2)] + sorted[(sorted.count / 2) - 1])) / 2
            } else {
                return Float(sorted[(sorted.count - 1) / 2])
            }
        }
        
        return nil
    }
    
 
    func getAvgPerNight(_ health2: [HealthData]) -> [HealthData]  {
        var avgs = [HealthData]()
        // Reset averages
        
        // Filter to valid HR data
        let health = health2.filter {
        #warning("disabled Night")
            return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && !$0.data.isNaN  && $0.data < 200 && $0.data > 0 && $0.date.getTimeOfDay() == "Night"
        }
        // Get start and end data
        let dates =  health.map{$0.date}.sorted(by: { $0.compare($1) == .orderedAscending })
        if let startDate = dates.first {
            
            
            if let endDate = dates.last {
                
                for date in Date.dates(from: startDate, to: endDate) {
                    
                    let todaysDate = health.filter{$0.date.get(.day) == date.get(.day) && $0.date.get(.month) == date.get(.month) && $0.date.get(.year) == date.get(.year)}
                    let avg = average(numbers: todaysDate.map{$0.data})
                    if  !avg.isNaN {
                        avgs.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: date, data: avg))
                        
                    } else {
                        if let first = todaysDate.map({$0.data}).first {
                            avgs.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: date, data: first))
                        } else {
                            
                        }
                    }
                }
            }
            
        }
        return avgs
    }
    
    func average(numbers: [Double]) -> Double {
        // print(numbers)
        return vDSP.mean(numbers)
    }

    func formatDate(_ startDate: Date) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        return dateFormatterGet.string(from: startDate)
        
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
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    var session = URLSession.shared
 
}
