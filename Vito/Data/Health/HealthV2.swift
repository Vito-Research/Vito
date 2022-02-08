//
//  HealthV2.swift
//  Vito
//
//  Created by Andreas Ink on 1/19/22.
//

import SwiftUI
import HealthKit
import Combine

class HealthV2: Healthv3 {
    
    @State var onboarding = UserDefaults.standard.bool(forKey: "onboarding")
    @State var medianOfAverages = UserDefaults.standard.double(forKey: "medianOfAverages")
    @Published var tempHealthData = HealthData(id: UUID().uuidString, type: .Feeling, title: "", text: "", date: Date(), data: 0.0)
   
    @Published var risks = [Double]()
    @Published var queryDate = Query(id: "", durationType: .Day, duration: 1, anchorDate: Date())
   // @Published var codableRisk = [CodableRisk(id: "NoData", date: Date().addingTimeInterval(-1000000000000), risk: 0.0, explanation: [String]())]
   
    @Published var healthChartData = ChartData(values: [("", 0.0)])
   
    override init() {
        super.init()
        sync()
        var stepDates = [Date]()
//        for i in 0...9 {
//        if let stepDate = Calendar.current.date(bySettingHour: i, minute: 00, second: 0, of: Date().addingTimeInterval(-86400)) {
//            stepDates.append(stepDate)
//        }
//        }
   //     populateAveragesData(_for: [Date().addingTimeInterval(-86400)], low: 70, high: 85, stepDates: stepDates)
            
        
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
   
 
  
    

   
  
//    func sync() {
//        var noDates = [String]()
//        if let earlyDate = Calendar.current.date(
//            byAdding: .month,
//            value: -12,
//            to: Date()) {
//            //Task {
//                for date in Date.dates(from: Calendar.current.startOfDay(for: earlyDate), to: Date()) {
//                    //print(date)
////                    DispatchQueue.main.async {
////                        //let sleep  = self.readSleep(from: Calendar.current.startOfDay(for: date), to:  Calendar.current.startOfDay(for: date).addingTimeInterval(86400))
////                        print("SLEEP")
////
////
////                    }
//
//                   // print(sleep.map{$0.date})
//                    //DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//
//
//
//                   // }
//
//               // }
//                //DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                    let calendar = Calendar.current
//
//                    for hour in 0...9 {
//
//                        let midnight = calendar.date(
//                          bySettingHour: hour,
//                          minute: 0,
//                          second: 0,
//                          of: date)!
//                        #warning("expand")
//                        let morning = calendar.date(
//                          bySettingHour: hour,
//                          minute: 59,
//                          second: 0,
//                          of: date)!
//
//                    self.getHealthData(startDate: midnight, endDate: morning, i: 1)
//                    self.getHealthData(startDate: midnight, endDate: morning, i: 0)
////                    }
//
//                    //DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//                       // print(self.hrData)
//                        noDates = self.hrData.filter{$0.data < 2 && $0.title == HKQuantityTypeIdentifier.stepCount.rawValue}.map{"\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))"}
//
//                        print(self.hrData.map{$0.data})
//                        //self.hrData = self.hrData.filter{$0.date.getTimeOfDay() == "Night"}
//                        //let grouped = self.groupByMonth()
//
////                               var monthlyGrouped = [HealthData]()
////                                for group in grouped {
////                                    print(group)
////                                    hrData2.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: group.first?.date ?? Date(), data: self.average(numbers: group.map{$0.data})))
////                                }
//
////                                let grouped2 = self.groupByDay(monthlyGrouped)
////
////                                for group in grouped2 {
////                                    print(group.first)
////                                    hrData2.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: group.first?.date ?? Date(), data: self.average(numbers: group.map{$0.data})))
////                                }
//                       // DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//
//
//
//
//                       // }
//                    //}
//               // }
//                    }
//            }
//            //DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//
//                //print(self.hrData.sliced(by: [.year, .month, .day], for: \.date).keys)
//
//                var filteredData = self.hrData.filter{!noDates.contains("\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))") && $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && $0.data < 200 && $0.data > 40}
//                filteredData = filteredData.sliced(by: [.year, .month, .day], for: \.date).map{ HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: $0.key, data: self.average(numbers: $0.value.map{$0.data}))}
//                filteredData =  filteredData.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
//               // print(filteredData.map{$0.date})
//            let avgs = self.getAvgPerNight(filteredData)
//                let risks  = self.getRiskScore(filteredData, avgs: avgs)
//                print(risks)
//                for i in filteredData.indices {
//
//                //let riskScore = self.average(numbers: Array(risks.dropFirst(risks.count - 2)))
////            if riskScore == 1 {
////                print("ALERT")
////
////            }
//                    //let data = filteredData[i]
//             //   let explanation =  riskScore > 0.99 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your heart rate while asleep is abnormally high compared to your previous data", detail: ""), Explanation(image: .app, explanation: "This can be a sign of disease, intoxication, lack of sleep, or other factors.", detail: ""), Explanation(image: .stethoscope, explanation: "This is not medical advice or a diagnosis, it's simply a datapoint to bring up to your doctor", detail: "")] : [Explanation(image: .checkmark, explanation: "Your heart rate while asleep is normal compared to your previous data", detail: ""), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, it's simply a datapoint to bring up to your doctor", detail: "")]
//                    for risk in risks {
//                        self.codableRisk.append(CodableRisk(id: UUID().uuidString, date: risk.date, risk: risk.data, explanation: []))
//                    }
//              //  self.risk = Risk(id: UUID().uuidString, risk: riskScore, explanation: explanation)
//            }
//           // }
//        }
//    }
//    func backgroundDelivery() {
//        var hrData2 = [HealthData]()
//        DispatchQueue.main.async {
//
//
//            self.healthStore.requestAuthorization(toShare: [], read: Set(self.readData)) { (success, error) in
//            self.healthStore.requestAuthorization(toShare: [], read:  Set([HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])) { (success, error) in
//
//                if success {
//        let readType2 = HKObjectType.quantityType(forIdentifier: .heartRate)
//
//            if let readType2 = readType2 {
//                //if self.healthStore.authorizationStatus(for: readType2) == .sharingAuthorized {
//                self.healthStore.enableBackgroundDelivery(for: readType2, frequency: .daily) { success, error in
//            if !success {
//                print("Error enabling background delivery for type \(readType2.identifier): \(error.debugDescription)")
//            } else {
//                print("Success enabling background delivery for type \(readType2.identifier)")
//                var noDates = [String]()
//                if let earlyDate = Calendar.current.date(
//                    byAdding: .month,
//                    value: -3,
//                    to: Date()) {
//                    //Task {
//                        for date in Date.dates(from: Calendar.current.startOfDay(for: earlyDate), to: Date()) {
//                            //print(date)
//        //                    DispatchQueue.main.async {
//        //                        //let sleep  = self.readSleep(from: Calendar.current.startOfDay(for: date), to:  Calendar.current.startOfDay(for: date).addingTimeInterval(86400))
//        //                        print("SLEEP")
//        //
//        //
//        //                    }
//
//                           // print(sleep.map{$0.date})
//                            //DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//
//
//
//                           // }
//
//                       // }
//                        //DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                            let calendar = Calendar.current
//
//                            for hour in 0...4 {
//
//                                let midnight = calendar.date(
//                                  bySettingHour: hour,
//                                  minute: 0,
//                                  second: 0,
//                                  of: date)!
//                                #warning("expand")
//                                let morning = calendar.date(
//                                  bySettingHour: hour,
//                                  minute: 59,
//                                  second: 0,
//                                  of: date)!
//
//                            self.getHealthData(startDate: midnight, endDate: morning, i: 1)
//                            self.getHealthData(startDate: midnight, endDate: morning, i: 0)
//        //                    }
//
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                               // print(self.hrData)
//                                noDates = self.hrData.filter{$0.data < 2 && $0.title == HKQuantityTypeIdentifier.stepCount.rawValue}.map{"\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))"}
//
//                                //print(self.hrData.map{$0.data})
//                                //self.hrData = self.hrData.filter{$0.date.getTimeOfDay() == "Night"}
//                                //let grouped = self.groupByMonth()
//
////                               var monthlyGrouped = [HealthData]()
////                                for group in grouped {
////                                    print(group)
////                                    hrData2.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: group.first?.date ?? Date(), data: self.average(numbers: group.map{$0.data})))
////                                }
//
////                                let grouped2 = self.groupByDay(monthlyGrouped)
////
////                                for group in grouped2 {
////                                    print(group.first)
////                                    hrData2.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: group.first?.date ?? Date(), data: self.average(numbers: group.map{$0.data})))
////                                }
//                               // DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//
//
//
//
//                                }
//                            //}
//                       // }
//                            }
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//
//                        //print(self.hrData.sliced(by: [.year, .month, .day], for: \.date).keys)
//
//                        self.hrData = self.hrData.filter{!noDates.contains("\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))") && $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && $0.data < 200}
//                        let filteredData = self.hrData.sliced(by: [.year, .month, .day], for: \.date).map{ HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: $0.key, data: self.average(numbers: $0.value.map{$0.data}))}
//
//                     //   print(filteredData.map{$0.date})
//                        let avgs = self.getAvgPerNight(filteredData)
//                        //print(avgs)
//                let risks  = self.getRiskScore(filteredData, avgs: avgs)
//                       // print(risks)
//                        if risks.count > 10 {
//                            let riskScore = self.average(numbers: Array(risks.map{$0.data}.dropFirst(risks.map{$0.data}.count - 2)))
//                    if riskScore == 1 {
//                        print("ALERT")
//
//                    }
//                        let explanation =  riskScore > 0.99 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your heart rate while asleep is abnormally high compared to your previous data", detail: ""), Explanation(image: .app, explanation: "This can be a sign of disease, intoxication, lack of sleep, or other factors.", detail: ""), Explanation(image: .stethoscope, explanation: "This is not medical advice or a diagnosis, it's simply a datapoint to bring up to your doctor", detail: "")] : [Explanation(image: .checkmark, explanation: "Your heart rate while asleep is normal compared to your previous data", detail: ""), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, it's simply a datapoint to bring up to your doctor", detail: "")]
//
//                        self.codableRisk.append(CodableRisk(id: UUID().uuidString, date: Date(), risk: riskScore, explanation: []))
//                        self.risk = Risk(id: UUID().uuidString, risk: riskScore, explanation: explanation)
//                    }
//                    }
//                }
//
//                    }
//            }
//                }
//        }
//            }
//            }
//
//        }
//    }
//    func populateAveragesData(_for targetDates: [Date], low: Int, high: Int, stepDates: [Date]) {
//
//            var noDates = [String]()
//            if let earlyDate = Calendar.current.date(
//                byAdding: .month,
//                value: -12,
//                to: Date()) {
//                //Task {
//                    for date in Date.dates(from: Calendar.current.startOfDay(for: earlyDate), to: Date()) {
//                        //print(date)
//    //                    DispatchQueue.main.async {
//    //                        //let sleep  = self.readSleep(from: Calendar.current.startOfDay(for: date), to:  Calendar.current.startOfDay(for: date).addingTimeInterval(86400))
//    //                        print("SLEEP")
//    //
//    //
//    //                    }
//
//                       // print(sleep.map{$0.date})
//                        //DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//
//
//
//                       // }
//
//                   // }
//                    //DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                        let calendar = Calendar.current
//                        for date in stepDates {
//                            self.hrData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.stepCount.rawValue, text: HKQuantityTypeIdentifier.stepCount.rawValue, date: date, data: 100))
//                            print(date)
//                        }
//                        for hour in 0...9 {
//
//                            let midnight = calendar.date(
//                              bySettingHour: hour,
//                              minute: 0,
//                              second: 0,
//                              of: date)!
//                            #warning("expand")
//                            let morning = calendar.date(
//                              bySettingHour: hour,
//                              minute: 59,
//                              second: 0,
//                              of: date)!
//                            if targetDates.map{$0.formatted(date: .abbreviated, time: .omitted)}.contains( date.formatted(date: .abbreviated, time: .omitted)) {
//                                for i in 0...3 {
//                                    self.hrData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: date.addingTimeInterval(TimeInterval(1200 * i)), data: Double(high)))
//                                }
//                            } else {
//                                for i in 0...3 {
//                                    self.hrData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: date.addingTimeInterval(TimeInterval(1200 * i)), data: Double(low)))
//                                }
//                            }
////                        self.getHealthData(startDate: midnight, endDate: morning, i: 1)
////                        self.getHealthData(startDate: midnight, endDate: morning, i: 0)
//    //                    }
//
//                        //DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//                           // print(self.hrData)
//                            noDates = self.hrData.filter{$0.data < 2 && $0.title == HKQuantityTypeIdentifier.stepCount.rawValue}.map{"\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))"}
//
//                            //print(self.hrData.map{$0.data})
//                            //self.hrData = self.hrData.filter{$0.date.getTimeOfDay() == "Night"}
//                            //let grouped = self.groupByMonth()
//
//    //                               var monthlyGrouped = [HealthData]()
//    //                                for group in grouped {
//    //                                    print(group)
//    //                                    hrData2.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: group.first?.date ?? Date(), data: self.average(numbers: group.map{$0.data})))
//    //                                }
//
//    //                                let grouped2 = self.groupByDay(monthlyGrouped)
//    //
//    //                                for group in grouped2 {
//    //                                    print(group.first)
//    //                                    hrData2.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: group.first?.date ?? Date(), data: self.average(numbers: group.map{$0.data})))
//    //                                }
//                           // DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//
//
//
//
//                            }
//                        //}
//                   // }
//                        }
//                }
//               // DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//
//                    //print(self.hrData.sliced(by: [.year, .month, .day], for: \.date).keys)
//
//                    var filteredData = self.hrData.filter{!noDates.contains("\($0.date.get(.hour))" + "\($0.date.get(.day))" + "\($0.date.get(.month))") && $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && $0.data < 200 && $0.data > 40}
//                    filteredData = filteredData.sliced(by: [.year, .month, .day], for: \.date).map{ HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: $0.key, data: self.average(numbers: $0.value.map{$0.data}))}
//                    filteredData =  filteredData.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
//                   // print(filteredData.map{$0.date})
//                let avgs = self.getAvgPerNight(filteredData)
//                    let risks  = self.getRiskScore(filteredData, avgs: avgs)
//                    print(risks)
////                    for i in filteredData.indices {
////
////                    //let riskScore = self.average(numbers: Array(risks.dropFirst(risks.count - 2)))
////    //            if riskScore == 1 {
////    //                print("ALERT")
////    //
////    //            }
////                        let data = filteredData[i]
////                 //   let explanation =  riskScore > 0.99 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your heart rate while asleep is abnormally high compared to your previous data", detail: ""), Explanation(image: .app, explanation: "This can be a sign of disease, intoxication, lack of sleep, or other factors.", detail: ""), Explanation(image: .stethoscope, explanation: "This is not medical advice or a diagnosis, it's simply a datapoint to bring up to your doctor", detail: "")] : [Explanation(image: .checkmark, explanation: "Your heart rate while asleep is normal compared to your previous data", detail: ""), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, it's simply a datapoint to bring up to your doctor", detail: "")]
////
////                        self.codableRisk.append(CodableRisk(id: UUID().uuidString, date: data.date, risk: risks[i], explanation: []))
////                  //  self.risk = Risk(id: UUID().uuidString, risk: riskScore, explanation: explanation)
////                }
//                    for risk in risks {
//                        self.codableRisk.append(CodableRisk(id: UUID().uuidString, date: risk.date, risk: risk.data, explanation: []))
//                    }
////                }
////            }
//        }
    
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
