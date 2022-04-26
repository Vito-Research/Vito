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
    var alertLvl = AlertLevelv3()
    var alertLvlRR = AlertLevelv3()
    var alertLvlHRV = AlertLevelv3()
    
    @State var fitbitData: [Date: FitbitData?] = [:]
    init() {
        //usingFitbit = false
        self.processData()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
//            self.riskData = self.getRiskScorev3(self.hrData, avgs: self.hrData)
//            if let lastRisk = self.riskData.last?.risk {
//                let explanation =  lastRisk > 0 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your heart rate while asleep is abnormally high compared to your previous data", detail: ""), Explanation(image: .app, explanation: "This can be a sign of disease, intoxication, lack of sleep, or other factors", detail: ""), Explanation(image: .stethoscope, explanation: "This is not medical advice or a diagnosis, it's simply a datapoint to bring up to your doctor", detail: "")] : [Explanation(image: .checkmark, explanation: "Your heart rate while asleep is normal compared to your previous data", detail: ""), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, it's simply a datapoint to bring up to your doctor", detail: "")]
//                self.risk = Risk(id: UUID().uuidString, risk: lastRisk, explanation: explanation)
//            }
//        }
    }
    func processData() {
        if usingFitbit {
            print(fitbitData)
            for fitbitData in fitbitData {
                if let hr = fitbitData.value {
                do {
                    
                    for data in hr.activitiesHeart {
                        print(data)
                        let date = fitbitData
                            if let restingHR = data.value.restingHeartRate {
                                var newData = HealthData(id: UUID().uuidString, type: .Health, title: "Fitbit", text: "Fitbit", date: fitbitData.key, data: Double(restingHR))
    //                    alertLvl.calculateMedian(Int(newData.data), newData.date)
    //
    //                    newData.risk = alertLvl.returnAlert()
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
                    
                       
                       
                            
                               
                            
                            
                        
                       
                        
                    
                    
                    
    //                let (samples, _, _) = try await hv4.queryHealthKit(HKObjectType.quantityType(forIdentifier: .heartRate)!, startDate: day, endDate: day.addingTimeInterval(86400))
    //                print(samples)
    //                let atRestHR = samples?.filter{$0.metadata?.values.first as! NSNumber == 1}
    //                let average = average(numbers: atRestHR.map{$0.map{$0.}})
                    
                    
                
                    
               
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
                content.subtitle = "Your health data may indicate that you may be becoming sick"
                content.sound = UNNotificationSound.default

                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)
//                LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
//                                                                           Today()
//                                                                               .at(hour: Date().get(.hour), minute: Date().get(.minute) + 1)
//                                                                               .schedule(title: "Significant P", body: "Your health data may indicate that you may be becoming sick, please consult your doctor")
//                                                                       }
            }
        }
        }
    }
    
    // Called on class initialization
//    init() {
//        // Gets when user is alseep, gets risk score, and enables background delivery
//       // backgroundDelivery()
//        self.healthStore.requestAuthorization(toShare: [], read: self.readData) { (success, error) in
//            self.retrieveSleepAnalysis(time: 100)
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                var stateMachine = AlertLevelv3()
//
//                for day in Date.dates(from: <#T##Date#>, to: <#T##Date#>)
//            //for day in self.healthData.sliced(by: [.day, .month, .year], for: \.date) {
//               // print(day)
//                self.getHealthData(startDate: day.value.map{$0.date}.min() ?? Date(), endDate: day.value.map{$0.date}.max()  ?? Date(), i: 0) { hr in
//                    if var hr =  hr {
//                        self.hrData.append(hr)
//                        stateMachine.calculateMedian(Int(hr.data), day.key)
//                        hr.risk = stateMachine.returnAlert()
//                        print(hr.risk)
//                        self.riskData.append(hr)
//                    }
//                }
//                //}
//
//            }
//       // self.getWhenNight()
//        }
//        Task {
//            do {
//       //try await sendToRedCap()
//            } catch {
//            }
//            }
//    }
   
   
    func backgroundDelivery() {
        
        self.healthStore.requestAuthorization(toShare: [], read: self.readData) { (success, error) in
        if let rr =  HKObjectType.quantityType(forIdentifier: .respiratoryRate) {
            self.healthStore.enableBackgroundDelivery(for: rr, frequency: .daily) { [self] sucess, error in
                if let max = riskData.map({$0.date}).max() {
                 let distance = max.distance(to: Date())
                    print(distance)
//            if let earlyDate = Calendar.current.date(
//                byAdding: .month,
//                value: distance,
//                to: Date()) {
                Task {
                    
                    for day in Date.dates(from: Date().addingTimeInterval(-distance), to: Date()) {
                  print(day)
                    
                do {
                    let hv4 = Healthv4()
                    if var newData = try await hv4.loadNewDataFromHealthKit(type: HKObjectType.quantityType(forIdentifier: .heartRate)!, unit: HKUnit(from: "count/min"), start: day, end: day.addingTimeInterval(86400)) {
                        if newData.data.isNormal {
    //                    alertLvl.calculateMedian(Int(newData.data), newData.date)
    //
    //                    newData.risk = alertLvl.returnAlert()
                            newData.risk = self.alertLvl.calculateMedian(Int(newData.data), newData.date, yellowThres: 3, redThres: 4)
                            self.riskData.append(newData)
                            self.hrData.append(newData)
                        } else {
                            
                        }
                    }
//                        if var newDataRR = try await hv4.loadNewDataFromHealthKit(type: HKObjectType.quantityType(forIdentifier: .respiratoryRate)!, unit: HKUnit(from: "count/min"), start: day, end: day.addingTimeInterval(86400)) {
//                            if newDataRR.data.isNormal {
//                            newDataRR.risk = self.alertLvlRR.calculateMedian(Int(newDataRR.data), newDataRR.date, yellowThres: 0, redThres: 1)
//                                //self.riskData.append(newDataRR)
//                                print(newDataRR)
//                            }
//                        }
//                            if var newDataHRV = try await hv4.loadNewDataFromHealthKit(type: HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!, unit: HKUnit(from: "ms"), start: day, end: day.addingTimeInterval(86400)) {
//
//                                if newDataHRV.data.isNormal {
//                                    newDataHRV.risk = self.alertLvlHRV.calculateMedianHRV(Int(newDataHRV.data), newDataHRV.date, yellowThres: 4, redThres: 5)
////                                    print(newDataHRV)
////                                    self.riskData.append(newDataHRV)
//                                }
//                            }
                       
                            
                               
                            
                            
                        
                       
                        
                    
                    
                    
    //                let (samples, _, _) = try await hv4.queryHealthKit(HKObjectType.quantityType(forIdentifier: .heartRate)!, startDate: day, endDate: day.addingTimeInterval(86400))
    //                print(samples)
    //                let atRestHR = samples?.filter{$0.metadata?.values.first as! NSNumber == 1}
    //                let average = average(numbers: atRestHR.map{$0.map{$0.}})
                    
                    
                } catch {
                }
                    
                }
                }
                
                    
                } else {
                    if let earlyDate = Calendar.current.date(
                                  byAdding: .month,
                                  value: -3,
                                  to: Date()) {
                    Task {
                        
                        for day in Date.dates(from: earlyDate, to: Date()) {
                      print(day)
                        
                    do {
                        let hv4 = Healthv4()
                        if var newData = try await hv4.loadNewDataFromHealthKit(type: HKObjectType.quantityType(forIdentifier: .heartRate)!, unit: HKUnit(from: "count/min"), start: day, end: day.addingTimeInterval(86400)) {
                            if newData.data.isNormal {
        //                    alertLvl.calculateMedian(Int(newData.data), newData.date)
        //
        //                    newData.risk = alertLvl.returnAlert()
                                newData.risk = self.alertLvl.calculateMedian(Int(newData.data), newData.date, yellowThres: 3, redThres: 4)
                                self.riskData.append(newData)
                                self.hrData.append(newData)
                            } else {
                                
                            }
                        }
    
                    
                                
         
                        
                    } catch {
                    }
                        
                    
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
    
//    func getWhenNight() {
//        var stateMachine = AlertLevelv3()
//        if let earlyDate = Calendar.current.date(
//            byAdding: .month,
//            value: -2,
//            to: Date()) {
//            // Loops through the dates by adding a day
//            for date in Date.dates(from: Calendar.current.startOfDay(for: earlyDate), to: Date()) {
//                if let earlyDate = Calendar.current.date(
//                    byAdding: .hour,
//                    value: 12,
//                    to: date) {
//                    if let lateTime = Calendar.current.date(
//                        byAdding: .hour,
//                        value: 8,
//                        to: date) {
//                    // Loop through the hours in a day
//
//                   // for date in Date.datesHourly(from: date, to: earlyDate) {
//                        // Get RR in that hour
//                       // if date.getTimeOfDay() == "Night" {
//                      //  getHealthData(startDate: date.addingTimeInterval(-3600), endDate: date.addingTimeInterval(3600), i: 2) { sleep in
//                            // If RR exists for that date keep going
//                         //   if let sleep =  sleep {
//                                // Loop through each hour within the time period of the RR
//                           //     for date in Date.datesHourly(from: sleep.date, to: sleep.endDate ?? Date()) {
//
//                                    // Get if steps are present in the time range
//                                    self.getHealthData(startDate: date.addingTimeInterval(-3600), endDate: date.addingTimeInterval(3600), i: 1) { steps in
//
//                                        // If steps are no-existant or below 100 for that hour, query HR data
//                                        if steps == nil || (steps?.data ?? 0) < 100 {
//
//                                            self.getHealthData(startDate: date.addingTimeInterval(-3600), endDate: date.addingTimeInterval(3600), i: 0) { hr in
//                                                if var hr =  hr {
//                                                    self.hrData.append(hr)
//                                                    stateMachine.calculateMedian(Int(hr.data), date)
//                                                    hr.risk = stateMachine.returnAlert()
//                                                    print(hr.risk)
//                                                    self.riskData.append(hr)
//                                                }
//
//                                            }
////                                        }
////                                    }
////                                }
//                         //   }
//                        }
//                                    }
//
//                       // }
//                    }
//                }
//            }
//        }
//        // After 5 seconds, get the average per night
////        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
////
////            self.avgs = self.getAvgPerNight(self.hrData)
////
////            // After 5 seconds, get the risk score per night
////            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
////                let risks  = self.getRiskScorev3(self.hrData, avgs: self.avgs)
////                // Set the riskData to risks
////                self.riskData = risks
////                // Set risk (the last night's risk) to the last risk
////                if let lastRisk = risks.last?.risk {
////                    let explanation =  lastRisk > 0 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your heart rate while asleep is abnormally high compared to your previous data", detail: ""), Explanation(image: .app, explanation: "This can be a sign of disease, intoxication, lack of sleep, or other factors", detail: ""), Explanation(image: .stethoscope, explanation: "This is not medical advice or a diagnosis, it's simply a datapoint to bring up to your doctor", detail: "")] : [Explanation(image: .checkmark, explanation: "Your heart rate while asleep is normal compared to your previous data", detail: ""), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, it's simply a datapoint to bring up to your doctor", detail: "")]
////                    self.risk = Risk(id: UUID().uuidString, risk: lastRisk, explanation: explanation)
////                }
////            }
////
////        }
//    }
//    func getWhenAsleep() {
//        // Gets the date 12 months ago
//        // if value = -12, becomes more sensitive
//        if let earlyDate = Calendar.current.date(
//            byAdding: .month,
//            value: -3,
//            to: Date()) {
//            // Loops through the dates by adding a day
//            for date in Date.dates(from: Calendar.current.startOfDay(for: earlyDate), to: Date()) {
//                if let earlyDate = Calendar.current.date(
//                    byAdding: .hour,
//                    value: 12,
//                    to: date) {
//                    // Loop through the hours in a day
//                    
//                    for date in Date.datesHourly(from: date, to: earlyDate) {
//                        // Get RR in that hour
//                        if date.getTimeOfDay() == "Night" {
//                        getHealthData(startDate: date.addingTimeInterval(-3600), endDate: date.addingTimeInterval(3600), i: 2) { sleep in
//                            // If RR exists for that date keep going
//                            if let sleep =  sleep {
//                                // Loop through each hour within the time period of the RR
//                                for date in Date.datesHourly(from: sleep.date, to: sleep.endDate ?? Date()) {
//                                    
//                                    // Get if steps are present in the time range
//                                    self.getHealthData(startDate: date.addingTimeInterval(-3600), endDate: date.addingTimeInterval(3600), i: 1) { steps in
//                                        
//                                        // If steps are no-existant or below 100 for that hour, query HR data
//                                        if steps == nil || (steps?.data ?? 0) < 100 {
//                                            
//                                            self.getHealthData(startDate: date.addingTimeInterval(-3600), endDate: date.addingTimeInterval(3600), i: 0) { hr in
//                                                if let hr =  hr {
//                                                    self.hrData.append(hr)
//                                                
//                                                }
//                                                
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        
//                        }
//                    }
//                }
//            }
//        }
//        // After 5 seconds, get the average per night
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            
//            self.avgs = self.getAvgPerNight(self.hrData)
//            
//            // After 5 seconds, get the risk score per night
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                let risks  = self.getRiskScorev3(self.hrData, avgs: self.avgs)
//                // Set the riskData to risks
//                self.riskData = risks
//                // Set risk (the last night's risk) to the last risk
//                if let lastRisk = risks.last?.risk {
//                    let explanation =  lastRisk > 0 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your heart rate while asleep is abnormally high compared to your previous data", detail: ""), Explanation(image: .app, explanation: "This can be a sign of disease, intoxication, lack of sleep, or other factors", detail: ""), Explanation(image: .stethoscope, explanation: "This is not medical advice or a diagnosis, it's simply a datapoint to bring up to your doctor", detail: "")] : [Explanation(image: .checkmark, explanation: "Your heart rate while asleep is normal compared to your previous data", detail: ""), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, it's simply a datapoint to bring up to your doctor", detail: "")]
//                    self.risk = Risk(id: UUID().uuidString, risk: lastRisk, explanation: explanation)
//                }
//            }
//            
//        }
//    }
    
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
    
    // Gets risk score
//    func getRiskScore(_ health: [HealthData], avgs: [HealthData]) -> [HealthData] {
//
//        var riskScores = [HealthData]()
//
//
//       // Alert level stays persistant through the loop
//        var alertLvl = 0
//        // let medianOfAvg = calculateMedian(array: avgs.map{$0.data})
//        for (avg, i2) in Array(zip(avgs, avgs.indices)) {
//            // Needs more than 3 days to calculate
//            if i2 > 3 {
//                // Gets the median of averages up to night i2
//                let medianOfAvg = calculateMedian(array: avgs.dropLast(avgs.count - i2).map{$0.data})
//
//                // if avg.date.getTimeOfDay() == "Night" {
//
//                // If the medianOfAvg + yellowThres is greater than the data, then alertLvl is set to zero
//                if avg.data < (Double(medianOfAvg) + yellowThres.0)  {
//                    // if alertLvl != 0 {
//
//                    alertLvl = 0
//                    // }
//                } else {
//                    // Switch through each alert possibility
//                    switch(alertLvl) {
//                    case 0:
//                        if avg.data >= (Double(medianOfAvg) + redThres.0)  {
//                            alertLvl = 2
//                        } else if avg.data >= (Double(medianOfAvg) + yellowThres.0) {
//                            alertLvl = 1
//                        }
//                        break
//                    case 1:
//                        if avg.data >= (Double(medianOfAvg) + redThres.0)  {
//                            alertLvl = 5
//                        } else if avg.data >= (Double(medianOfAvg) + yellowThres.0) {
//                            alertLvl = 3
//                        }
//                        break
//                    case 2:
//                        if avg.data >= (Double(medianOfAvg) + redThres.0)  {
//                            alertLvl = 5
//                        }  else if avg.data >= (Double(medianOfAvg) + yellowThres.0) {
//                            alertLvl = 3
//                        }
//                        break
//                    case 3:
//                        if avg.data >= (Double(medianOfAvg) + redThres.0)  {
//                            alertLvl = 4
//                        }  else {
//                            alertLvl = 3
//                        }
//                        break
//
//                    // Yellow Alert Level
//                    case 4:
//                        if avg.data >= (Double(medianOfAvg) + redThres.0)  {
//                            alertLvl = 5
//                        } else if avg.data >= (Double(medianOfAvg) + yellowThres.0)  {
//
//                            alertLvl = 3
//                        }
//                        break
//
//                    // Red Alert Level
//                    case 5:
//                        if avg.data >= (Double(medianOfAvg) + redThres.0) {
//                            alertLvl = 5
//                        } else if avg.data >= (Double(medianOfAvg) + yellowThres.0) {
//                            alertLvl = 3
//                        }
//                        break
//                    default:
//                        alertLvl = 0
//                        break
//                    }
//
//
//
//                }
//
//            }
//            // Append the risk score
//            riskScores.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: avg.date, data: avg.data, risk: Double(alertLvl)))
//        }
//
//        // Return risk scores
//        return riskScores
//    }
        //func getRiskScorev3(_ health: [HealthData], avgs: [HealthData]) -> [HealthData]
//   {
//
//       var riskScores = [HealthData]()
//
//       var alertLvl = AlertLevelv3()
//
//       var confirmedRedAlerts = [HealthData]()
//      // Alert level stays persistant through the loop
//
//       // let medianOfAvg = calculateMedian(array: avgs.map{$0.data})
//       for (avg, i2) in Array(zip(avgs, avgs.indices)) {
//           // Needs more than 3 days to calculate
//          // if i2 > 3 {
//               // Gets the median of averages up to night i2
//
//          // print(alertLvl)
//           riskScores.append(HealthData(id: UUID().uuidString, type: .Health, title: "", text: "", date: avg.date, data: Double(Int(avg.data)), risk: alertLvl.calculateMedian((Int(avg.data)), avg.date)))
////           let filteredAvgs = (avgs.dropLast((avgs.count - i2)))//.filter{!redAlerts.map{$0.date.formatted(date: .numeric, time: .omitted)}.contains($0.date.formatted(date: .numeric, time: .omitted))}
////               let medianOfAvg = calculateMedian(array: filteredAvgs.map{$0.data})
//
//              // }
//       }
////       var track = [HealthData]()
////       for (avg, i2) in Array(zip(redAlerts, redAlerts.indices)) {
////
////           let today = avg
////           if redAlerts.indices.contains(i2 + 1) {
////           let next = redAlerts[i2 + 1]
////               if next.date.distance(to: today.date) <= 86400 {
////           if(track.contains(today)) {
////               confirmedRedAlerts.append(redAlerts[i2 + 1])
////               track.append(next)
////           } else {
////               confirmedRedAlerts.append(redAlerts[i2 + 1])
////               track.append(today)
////               track.append(next)
////           }
////               }
////
////       }
////
////       }
//
//       // Return risk scores
//
//
//       return riskScores
//}
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
                            
                            //avgs.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: date, data: average(numbers: [avgs.last?.data ?? 0, avgs[avgs.count - 2].data])))
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
//    func populateAveragesData(_for targetDates: [Date], low: Int, high: Int, stepDates: [Date]) {
//
//        var noDates = [String]()
//        if let earlyDate = Calendar.current.date(
//            byAdding: .month,
//            value: -12,
//            to: Date()) {
//            for date in Date.dates(from: Calendar.current.startOfDay(for: earlyDate), to: Date()) {
//
//
//                for date in stepDates {
//                    self.hrData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.stepCount.rawValue, text: HKQuantityTypeIdentifier.stepCount.rawValue, date: date, data: 100))
//                    print(date)
//                }
//               // for hour in 0...6 {
//
//
//                    if targetDates.map({$0.formatted(date: .abbreviated, time: .omitted)}).contains( date.formatted(date: .abbreviated, time: .omitted)) {
//                        for i in 0...3 {
//                            self.hrData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: date.addingTimeInterval(TimeInterval(1200 * i)), data: Double(high)))
//                        }
//                    } else {
//                        for i in 0...3 {
//                            self.hrData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: date.addingTimeInterval(TimeInterval(1200 * i)), data: Double(low)))
//                        }
//                    }
//
//                    noDates = self.hrData.filter{$0.data < 2 && $0.title == HKQuantityTypeIdentifier.stepCount.rawValue}.map{"\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))"}
//
//
//              //  }
//
//            }
//        }
//
//
//        var filteredData = self.hrData.filter{!noDates.contains("\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))") && $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && $0.data < 200 && $0.data > 40}
//        filteredData = filteredData.sliced(by: [.year, .month, .day], for: \.date).map{ HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: $0.key, data: self.average(numbers: $0.value.map{$0.data}))}
//        filteredData =  filteredData.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
//        // print(filteredData.map{$0.date})
//        self.getAvgPerNight(filteredData)
//        let risks  = self.getRiskScore(filteredData, avgs: self.avgs)
//        print(risks)
//
//        for risk in risks {
//            self.codableRisk.append(CodableRisk(id: UUID().uuidString, date: risk.date, risk: risk.data, explanation: []))
//        }
//    }
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
//    func sendToRedCap() async throws -> FitbitData? {
//
//
//            var request = URLRequest(url: URL(string: "https://redcapdemo.vanderbilt.edu/api/")!)
//   //
//        ML().exportDataToCSV(data: healthData, codableRisk: codableRisk) { isDone in
//
//        }
//        request.httpMethod = "POST"
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        let data = RedCapData(data: String(data: try Data(contentsOf: getDocumentsDirectory().appendingPathComponent("Vito_Health_Data.csv")), encoding: .utf8) ?? "")
//        print(data)
//        print(request)
//
//            let res = try await session.upload(
//                 for: request,
//                 from: try JSONEncoder().encode(data)
//
//             )
//            print(res.1)
//            let jsonDecoder = JSONDecoder()
//
//            return try jsonDecoder.decode(FitbitData.self, from: res.0)
//    //
//    }
}
