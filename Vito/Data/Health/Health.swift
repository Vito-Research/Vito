//
//  Health.swift
//  Health
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
import NiceNotifications
import Combine
import HKCombine

class Health: ObservableObject {
   
    
    @Published var codableRisk = [CodableRisk(id: "NoData", date: Date().addingTimeInterval(-1000000000000), risk: 0.0, explanation: [String]())]
    @Published var healthStore = HKHealthStore()
    @Published var risk = Risk(id: "NoData", risk: 21, explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Explain it here!!", detail: ""), Explanation(image: .questionmarkCircle, explanation: "Explain it here?", detail: ""), Explanation(image: .circle, explanation: "Explain it here.", detail: "")])
   // @Published var readData: [HKQuantityTypeIdentifier] =  [.stepCount, .respiratoryRate, .oxygenSaturation]
    var healthData = [HealthData]()
    @Published var tempHealthData = HealthData(id: UUID().uuidString, type: .Feeling, title: "", text: "", date: Date(), data: 0.0)
    @Published var healthChartData = ChartData(values: [("", 0.0)])
    @Published var todayHeartRate = [HealthData]()
    @State var onboarding = UserDefaults.standard.bool(forKey: "onboarding")
    @State var medianOfAverages = UserDefaults.standard.double(forKey: "medianOfAverages")
    
    let calorieQuantity = HKUnit(from: "cal")
    let heartrateQuantity = HKUnit(from: "count/min")
      
    @Published var queryDate = Query(id: "", durationType: .Day, duration: 1, anchorDate: Date())

//    @Published var hasWatchOS8 = UserDefaults.standard.bool(forKey: "hasWatchOS8")
    init() {
        getCodableRisk()
        
    }
    func getCodableRisk() {
        let url3 = getDocumentsDirectory().appendingPathComponent("risk.txt")
        do {
            
            let input = try String(contentsOf: url3)
            
            
            let jsonData = Data(input.utf8)
            do {
                let decoder = JSONDecoder()
                
                do {
                    let codableRisk = try decoder.decode([CodableRisk].self, from: jsonData)
                    
                    self.codableRisk = codableRisk
                    
                 
                } catch {
                    print(error.localizedDescription)
                }
            }
        } catch {
            
        }
    }
    let readData = Set([
            
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
       // HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
        
    ])
    
    let units: [HKUnit] = [HKUnit(from: "count/min"), HKUnit(from: "count/min")]
    let quanityTypes: [String] = ["Avg", "Avg"]
    
    func backgroundDelivery() {
        DispatchQueue.main.async {
            
            
            self.healthStore.requestAuthorization(toShare: [], read: self.readData) { (success, error) in
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
              // Gets a date from 3 months back
                let earlyDate = Calendar.current.date(
                  byAdding: .month,
                  value: -3,
                  to: Date())
              // Queries active energy to determine when the user is alseep
                self.healthData.removeAll()
               // self.getRespiratoryHealthData(startDate: earlyDate ?? Date(), endDate: Date())
                    //self.getActiveEnergyHealthData(startDate: earlyDate ?? Date(), endDate: Date())
                self.retrieveSleepAnalysis(time: 100, start: earlyDate ?? Date())
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // loops thru the active energy data
//                    if self.healthData.isEmpty {
//                        self.getActiveEnergyHealthData(startDate: earlyDate ?? Date(), endDate: Date())
//                        for data in self.healthData {
//                            // Gets dates 5 minutes before and after the start date of low active energy
//                            let earlyDate = Calendar.current.date(
//                              byAdding: .minute,
//                              value: -5,
//                              to: data.date)
//                            let lateDate = Calendar.current.date(
//                              byAdding: .minute,
//                              value: 5,
//                              to: data.date)
//                        // Gets heartrate data from the specified dates above
//                            self.getHeartRateHealthData(startDate: earlyDate ?? Date(), endDate:  lateDate ?? Date())
//
//                        }
//                    } else {
                    self.healthData = self.groupByDay().first ?? []
                    for i in self.healthData.indices {
                    // Gets dates 5 minutes before and after the start date of low active energy
                    let earlyDate = self.healthData[i].date
                    
                
                    let lateDate =  self.healthData[i].text.toDate() ?? Date()
                    print(lateDate)
                        for i2 in Array(self.readData).indices {
                        self.getHealthData(startDate: earlyDate, endDate: lateDate, i: i2)
                        }
//                    for date in Date.datesHourly(from: earlyDate, to: lateDate) {
//                    let earlyDate = Calendar.current.date(
//                      byAdding: .minute,
//                      value: -30,
//                      to: date)
//                    let lateDate = Calendar.current.date(
//                      byAdding: .minute,
//                      value: 30,
//                      to: date)
//                        if let earlyDate = earlyDate {
//                            if let lateDate = lateDate {
//                                for i2 in Array(self.readData).indices {
//                        self.getHealthData(startDate: earlyDate, endDate: lateDate, i: i2)
//                                }
//                        }
//                        }
////                    self.getHealthData(startDate: earlyDate ?? Date(), endDate:  lateDate ?? Date(), id: .heartRateVariabilitySDNN, quanityType: HKUnit(from: "ms"))
////                    self.getHealthData(startDate: earlyDate ?? Date(), endDate:  lateDate ?? Date(), id: .respiratoryRate, quanityType: self.heartrateQuantity)
////                    self.getHealthData(startDate: earlyDate ?? Date(), endDate:  lateDate ?? Date(), id: .stepCount, quanityType: HKUnit(from: "count"))
//
//               // }
//                    }
                }
               
               
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        let avg  = self.getAvgPerNight(self.healthData)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
              // Calculates risk based on heartrate data
                        //self.risk = self.getRiskScorev2(date: Date())
                        let risk = (self.getRiskScore(self.healthData, avgs: avg))
                        print("HEERE")
                        print(risk)
                                    }
                    }

                   
              //  }
            }
                    }
            }
                }
        }
            }
            }
            
        }
    }
    func groupByDay() -> [[HealthData]] {
        guard !self.healthData.isEmpty else { return [] }
        let dictionaryByMonth = Dictionary(grouping: self.healthData, by: { $0.date.get(.day) })
      let months = Array(1...30) // rotate this array if you want to go from October to September
      return months.compactMap({ dictionaryByMonth[$0] })
    }
  // If this is @State, it breaks the code, keep it as a regular var
    var cancellableBag = Set<AnyCancellable>()
    var cancellableBag2 = Set<AnyCancellable>()
    // Gets active energy to determine when the user is alseep
    func getActiveEnergyHealthData(startDate: Date, endDate: Date) {
       
        healthStore
            .get(sample: HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!, start: startDate, end: endDate)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [HKQuantitySample]())
            .sink(receiveCompletion: { subscription in

            }, receiveValue: { samples in
                // Loops thru active energy samples
                for sample in samples {
                  
                    // If active energy is low (below 1.4 in healthkit app terms) and does not equal zero then add the heartrate data to healthData
                    
                  //  if sample.quantity.doubleValue(for: self.calorieQuantity) < 101 && sample.quantity.doubleValue(for: self.calorieQuantity) != 0.0 {
                    self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)?.identifier ?? "", text: "", date: sample.startDate, data: sample.endDate.timeIntervalSince1970))
                   
//                    } else {
//
//                    }
                }
            // Does something, lol
            }).store(in: &cancellableBag)
    }

    func retrieveSleepAnalysis(time: Int, start: Date) {
        
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: [])
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: time, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    // something happened
                    return
                    
                }
                
                if let result = tmpResult {
                    
                    // do something with my data
                    for item in result {
                        if let sample = item as? HKCategorySample {
                           
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(sample.value)")
                            
                            if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue || sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue  {
                            self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: "", text:  sample.endDate.getFormattedDate(format: "yyyy-MM-dd HH:mm:ss"), date: sample.startDate, data: (sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue) ? 1 : 0))
                            }
                            //(sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue)
                        }
                    }
                }
            }
            
            // finally, we execute our query
            healthStore.execute(query)
        }
    }
    func getSleepData(startDate: Date, endDate: Date) {
       
        healthStore
            .get(sample: HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!, start: startDate, end: endDate)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [HKQuantitySample]())
            .sink(receiveCompletion: { subscription in

            }, receiveValue: { samples in
                // Loops thru active energy samples
                for sample in samples {
                  
                    // If active energy is low (below 1.4 in healthkit app terms) and does not equal zero then add the heartrate data to healthData
                    
                   
                    self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!.identifier , text: "", date: sample.startDate, data: sample.endDate.timeIntervalSince1970))
                   
                    
                }
            // Does something, lol
            }).store(in: &cancellableBag)
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
                         self.healthData.append(HealthData(id: "\(i)", type: DataType(rawValue: Array(self.readData)[i].identifier) ?? .Health, title: Array(self.readData)[i].identifier, text: Array(self.readData)[i].identifier, date: stat.startDate, data: quanity))
                     }
                     
                }
            // Does something, lol
            }).store(in: &cancellableBag)
        //return true
    }
    // Gets all months
    @Environment(\.calendar) var calendar
    let interval = DateInterval()
     var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
    
    // Calculates risk score
    func getRiskScorev2(date: Date) -> Risk {
        // Filters to heartrate type
        var varRisk = Risk(id: "NoData", risk: 21.0, explanation: [Explanation]())
        let filteredToHeartRate = healthData.filter {
            return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && !$0.data.isNaN //&& $0.date.getTimeOfDay() == "Night"
        }
        let filteredToRespiratoryRate = healthData.filter {
            return $0.title == HKQuantityTypeIdentifier.respiratoryRate.rawValue && !$0.data.isNaN
        }
        var averagePerNights = [Double]()
        var averagePerNightsR = [Double]()
        for month in months {
            // If month is within 3 months in the past then proceed
            //if (month.get(.month) >= date.get(.month) - 2 && month.get(.month) <= date.get(.month))  {
                
        for day in 0...32 {
            // Filter to day and to month that's not today
            let filteredToDay = filteredToHeartRate.filter {
                return $0.date.get(.day) == day && $0.date.get(.day) != date.get(.day) &&  $0.date.get(.month) == month.get(.month)
            }
            let filteredToDayR = filteredToRespiratoryRate.filter {
                return $0.date.get(.day) == day && $0.date.get(.day) != date.get(.day) &&  $0.date.get(.month) == month.get(.month)
            }
            // Get average for that day
            averagePerNights.append(average(numbers: filteredToDay.map{$0.data}))
            averagePerNightsR.append(average(numbers: filteredToDayR.map{$0.data}))
        }
           // }
        }
        // Get median of the averages for each day
        print(averagePerNights)
        let median = averagePerNights.filter{!$0.isNaN}.median()
        let medianR = averagePerNightsR.filter{!$0.isNaN}.median()
        print("MEDIAN")
        print(median)
        // Filter to current night
        #warning("If new month could cause an issue")
        let filteredToLastNight = filteredToHeartRate.filter {
            return $0.date.get(.day) == date.get(.day) && $0.date.get(.month) == date.get(.month)
        }
        
        let filteredToLastNightR = filteredToRespiratoryRate.filter {
            return $0.date.get(.day) == date.get(.day) && $0.date.get(.month) == date.get(.month)
        }
        print("LAST NIGHT")
        print(filteredToLastNight)
        print( average(numbers: filteredToLastNight.map{$0.data}))
        // Calculate risk
        if median != 21 {
            
        
        let averageLastNight = average(numbers: filteredToLastNight.map{$0.data})
        var riskScore = averageLastNight >= median + 4.0 ? 1.0 : averageLastNight >= median + 3.0 ? 0.3 : 0.0
        // If average of last night's respiratory rate is over a certain treshold, then add to risk
        #warning("Respiratory Rate needs to be tested further")
        if medianR + 4 < average(numbers: filteredToLastNightR.map{$0.data}) {
            riskScore += 0.2
        }
        // Populates explaination depending on severity of risk
            let explanation =  riskScore == 1 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your heart rate while asleep is abnormally high compared to your previous data", detail: ""), Explanation(image: .app, explanation: "This can be a sign of disease, intoxication, lack of sleep, or other factors.", detail: ""), Explanation(image: .stethoscope, explanation: "This is not medical advice or a diagnosis, it's simply a datapoint to bring up to your doctor", detail: "")] : [Explanation(image: .checkmark, explanation: "Your heart rate while asleep is normal compared to your previous data", detail: ""), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, it's simply a datapoint to bring up to your doctor", detail: "")]
    // Initalize risk
    let risk = Risk(id: UUID().uuidString, risk: CGFloat(riskScore), explanation: explanation)
  
    #warning("maybe increase")
    if averagePerNights.count > 0 && filteredToLastNight.count > 0 {
    withAnimation(.easeOut(duration: 1.3)) {
    // Populate risk var with local risk var
      
        varRisk = risk
    }
      
        let riskScore = risk.risk
            if  riskScore > 0.5 && riskScore != 21.0 {
               
                                           if self.codableRisk.indices.contains(self.codableRisk.count - 2) {
                                               if (self.codableRisk[self.codableRisk.count - 2]).risk > 0.5 {
                                                   if self.codableRisk[self.codableRisk.count - 2].date.get(.day) + 1 == self.codableRisk.last?.date.get(.day) ?? 0 {


                                                       LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
                                                           Today()
                                                               .at(hour: Date().get(.hour), minute: Date().get(.minute) + 1)
                                                               .schedule(title: "Significant HR Increase", body: "Your health data may indicate your heartrate is increasing while asleep")
                                                       }
                                         
                                           }

                                           }
                                           }
            }
        // Add risk to codeableRisk
   
        self.codableRisk.append(CodableRisk(id: risk.id, date:date, risk: risk.risk, explanation: [String]()))
        
        
    } else {
      // If averagePerNights is empty then populate risk with 21 to indicate that
        if date.get(.day) == Date().get(.day) {
  varRisk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your smart watch as you sleep to see your data", detail: "")])
        }
    
    }
        } else {
            if date.get(.day) == Date().get(.day) {
                varRisk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your smart watch as you sleep to see your data", detail: "")])
            }
        }
        return varRisk
    }
    func getRiskScore(_ health: [HealthData], avgs: [Double]) -> [Double] {
        var riskScores = [Double]()
        let medianOfAvg = calculateMedian(array: avgs)
        print(medianOfAvg)
        for avg in avgs {
            
            riskScores.append(avg >= Double(medianOfAvg) + 4.0 ? 1.0 : avg >= Double(medianOfAvg) + 3.0 ? 0.3 : 0.0)
        }
        return riskScores
    }
    func getAvgPerNight(_ health: [HealthData]) -> [Double] {
        var avgPerNight = [Double]()
        let health = healthData.filter {
            return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && !$0.data.isNaN //&& $0.date.getTimeOfDay() == "Night"
        }
        let dates =  health.map{$0.date}.sorted(by: { $0.compare($1) == .orderedDescending })
        if let startDate = dates.last      {
            
            
            if let endDate = dates.first {
                
                for date in Date.dates(from: startDate, to: endDate) {
                    
                    let todaysDate = health.filter{formatDate($0.date) == formatDate(date)}
                    
                    avgPerNight.append(average(numbers: todaysDate.map{$0.data}))
                    print(avgPerNight)
                }
            }
            
        }
        return avgPerNight
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
    func calculateMedian(array: [Double]) -> Float {
        let sorted = array.sorted().filter{!$0.isNaN}
        if sorted.count % 2 == 0 {
                return Float((sorted[(sorted.count / 2)] + sorted[(sorted.count / 2) - 1])) / 2
            } else {
                return Float(sorted[(sorted.count - 1) / 2])
            }
        }
   // Gets average of input and outputs
    func average(numbers: [Double]) -> Double {
       // print(numbers)
       return Double(numbers.reduce(0,+))/Double(numbers.count)
   }
    func convertHealthDataToChart(healthData: [HealthData], completionHandler: @escaping (ChartData) -> Void) {
        
        for data in healthData {
            healthChartData.points.append((data.type.rawValue,  data.data*10))
            
        }
        completionHandler(healthChartData)
    }
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}
