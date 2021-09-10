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
   
    
    @Published var codableRisk = [CodableRisk(id: UUID().uuidString, date: Date().addingTimeInterval(-1000000000000), risk: 0.0, explanation: [String]())]
    @Published var healthStore = HKHealthStore()
    @Published var risk = Risk(id: "", risk: 21, explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Explain it here!!"), Explanation(image: .questionmarkCircle, explanation: "Explain it here?"), Explanation(image: .circle, explanation: "Explain it here.")])
    @Published var readData: [HKQuantityTypeIdentifier] =  [.stepCount, .respiratoryRate, .oxygenSaturation]
    @Published var healthData = [HealthData]()
    @Published var tempHealthData = HealthData(id: UUID().uuidString, type: .Feeling, title: "", text: "", date: Date(), data: 0.0)
    @Published var healthChartData = ChartData(values: [("", 0.0)])
    @Published var todayHeartRate = [HealthData]()
    @State var onboarding = UserDefaults.standard.bool(forKey: "onboarding")
    @State var medianOfAverages = UserDefaults.standard.double(forKey: "medianOfAverages")
    
    let calorieQuantity = HKUnit(from: "cal")
    let heartrateQuantity = HKUnit(from: "count/min")
      
    @Published var queryDate = Query(id: "", durationType: .Day, duration: 1, anchorDate: Date())

    
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
    func backgroundDelivery() {
        DispatchQueue.main.async {
            
            let readData = Set([
//                    HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
               // HKCategoryType(.sleepAnalysis),
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
               // HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .stepCount)!
            ])
            
            self.healthStore.requestAuthorization(toShare: [], read: readData) { (success, error) in
                
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
                    self.getActiveEnergyHealthData(startDate: earlyDate ?? Date(), endDate: Date())
 
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // loops thru the active energy data
                   
                for data in self.healthData {
                    // Gets dates 5 minutes before and after the start date of low active energy
                    let earlyDate = Calendar.current.date(
                      byAdding: .minute,
                      value: -5,
                      to: data.date)
                    let lateDate = Calendar.current.date(
                      byAdding: .minute,
                      value: 5,
                      to: data.date)
                // Gets heartrate data from the specified dates above
                    self.getHeartRateHealthData(startDate: earlyDate ?? Date(), endDate:  lateDate ?? Date())
                    //self.getRespiratoryHealthData(startDate: earlyDate ?? Date(), endDate:  lateDate ?? Date())
                }
               
               
               
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
              // Calculates risk based on heartrate data
                        self.getRiskScorev2()

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
    func syncAllData() {
      
            let earlyDate = Calendar.current.date(
              byAdding: .month,
              value: -3,
              to: Date())
           
           
                self.getActiveEnergyHealthData(startDate: earlyDate ?? Date(), endDate: Date())
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for data in self.healthData {
              
                let earlyDate = Calendar.current.date(
                  byAdding: .minute,
                  value: -5,
                  to: data.date)
                let lateDate = Calendar.current.date(
                  byAdding: .minute,
                  value: 5,
                  to: data.date)
              
                self.getHeartRateHealthData(startDate: earlyDate ?? Date(), endDate:  lateDate ?? Date())

            }
           
           
         
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
         
                    self.getRiskScorev2()

                }

             

        }

           
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
                    
                    if sample.quantity.doubleValue(for: self.calorieQuantity) < 101 && sample.quantity.doubleValue(for: self.calorieQuantity) != 0.0 {
                    self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)?.identifier ?? "", text: "", date: sample.startDate, data: sample.endDate.timeIntervalSince1970))
                   
                    } else {
                       
                    }
                }
            // Does something, lol
            }).store(in: &cancellableBag)
    }
    func getHeartRateHealthData(startDate: Date, endDate: Date) {

        healthStore
            .get(sample: HKSampleType.quantityType(forIdentifier: .heartRate)!, start: startDate, end: endDate)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { subscription in
         
            }, receiveValue: { samples in
         
                // If there's smaples then add the sample to healthData
                if samples.count > 0 {
                self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKSampleType.quantityType(forIdentifier: .heartRate)?.identifier ?? "", text: "", date: startDate, data: self.average(numbers: samples.map{$0.quantity.doubleValue(for: self.heartrateQuantity)})))
                }
            // Does something, lol
            }).store(in: &cancellableBag2)
    }
    func getRespiratoryHealthData(startDate: Date, endDate: Date) {

        healthStore
            .get(sample: HKSampleType.quantityType(forIdentifier: .respiratoryRate)!, start: startDate, end: endDate)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { subscription in
         
            }, receiveValue: { samples in
         
                // If there's smaples then add the sample to healthData
                if samples.count > 0 {
                self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKSampleType.quantityType(forIdentifier: .respiratoryRate)?.identifier ?? "", text: "", date: startDate, data: self.average(numbers: samples.map{$0.quantity.doubleValue(for: self.heartrateQuantity)})))
                }
            // Does something, lol
            }).store(in: &cancellableBag2)
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
    func getRiskScorev2() {
        // Filters to heartrate type
        let filteredToHeartRate = healthData.filter {
            return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue && !$0.data.isNaN
        }
        let filteredToRespiratoryRate = healthData.filter {
            return $0.title == HKQuantityTypeIdentifier.respiratoryRate.rawValue && !$0.data.isNaN
        }
        var averagePerNights = [Double]()
        var averagePerNightsR = [Double]()
        for month in months {
            // If month is within 3 months in the past then proceed
            if (month.get(.month) >= Date().get(.month) - 2 && month.get(.month) <= Date().get(.month))  {
                
        for day in 0...32 {
            // Filter to day and to month that's not today
            let filteredToDay = filteredToHeartRate.filter {
                return $0.date.get(.day) == day && $0.date.get(.day) != Date().get(.day) &&  $0.date.get(.month) == month.get(.month)
            }
            let filteredToDayR = filteredToRespiratoryRate.filter {
                return $0.date.get(.day) == day && $0.date.get(.day) != Date().get(.day) &&  $0.date.get(.month) == month.get(.month)
            }
            // Get average for that day
            averagePerNights.append(average(numbers: filteredToDay.map{$0.data}))
            averagePerNightsR.append(average(numbers: filteredToDayR.map{$0.data}))
        }
            }
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
            return $0.date.get(.day) == Date().get(.day) && $0.date.get(.month) == Date().get(.month)
        }
        
        let filteredToLastNightR = filteredToRespiratoryRate.filter {
            return $0.date.get(.day) == Date().get(.day) && $0.date.get(.month) == Date().get(.month)
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
        let explanation =  riskScore == 1 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your heart rate while asleep is abnormally high compared to your previous data"), Explanation(image: .app, explanation: "This can be a sign of disease, intoxication, lack of sleep, or other factors."), Explanation(image: .stethoscope, explanation: "This is not medical advice or a diagnosis, it's simply a datapoint to bring up to your doctor")] : [Explanation(image: .checkmark, explanation: "Your heart rate while asleep is normal compared to your previous data"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, it's simply a datapoint to bring up to your doctor")]
    // Initalize risk
    let risk = Risk(id: UUID().uuidString, risk: CGFloat(riskScore), explanation: explanation)
  
    #warning("maybe increase")
    if averagePerNights.count > 0 && filteredToLastNight.count > 0 {
    withAnimation(.easeOut(duration: 1.3)) {
    // Populate risk var with local risk var
    self.risk = risk
        
    }
      
        let riskScore = risk.risk
            if  riskScore > 0.5 && riskScore != 21.0 {
               
                                           if self.codableRisk.indices.contains(self.codableRisk.count - 2) {
                                               if (self.codableRisk[self.codableRisk.count - 2]).risk > 0.5 {
                                                   if self.codableRisk[self.codableRisk.count - 2].date.get(.day) + 1 == self.codableRisk.last?.date.get(.day) ?? 0 {


                                                       LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
                                                           Today()
                                                               .at(hour: Date().get(.hour), minute: Date().get(.minute) + 1)
                                                               .schedule(title: "Significant Risk", body: "Your health data may indicate that you may be becoming sick, please consult your doctor")
                                                       }
                                         
                                           }

                                           }
                                           }
            }
        // Add risk to codeableRisk
        self.codableRisk.append(CodableRisk(id: risk.id, date: Date(), risk: risk.risk, explanation: [String]()))
     
    } else {
      // If averagePerNights is empty then populate risk with 21 to indicate that
        self.risk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your Apple Watch as you sleep to see your data")])
    
    }
        } else {
            self.risk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your Apple Watch as you sleep to see your data")])
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
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

