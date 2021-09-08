//
//  ML.swift
//  ML
//
//  Created by Andreas on 8/17/21.
//
#if targetEnvironment(simulator)

#else
import SwiftUI
import CoreML
import CreateML
import TabularData
import HealthKit
@available(iOS 15, *)
class ML: ObservableObject {
    @Published var mlData = ModelResponse(type: "", predicted: [Double](), actual: [Double](), accuracy: 0.0)
    
    func importCSV(data: DataFrame, completionHandler: @escaping ([HealthData]) -> Void) {
        var healthData = [HealthData]()
       
        for row in data.rows {
            
            let date = ((row["Start_Date"] as! String) + " " + (row["Start_Time"] as! String)).toDate()!
            healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: HKQuantityTypeIdentifier.heartRate.rawValue, text: HKQuantityTypeIdentifier.heartRate.rawValue, date: date, data: Double(row["Heartrate"] as! Int)))
            
            //print(healthData.map{$).data})
        }
        
        completionHandler(healthData)
    }
    func exportDataToCSV(data: [HealthData], completionHandler: @escaping (Bool) -> Void) {
        var trainingData = DataFrame()
        print("Exporting...")
        let filteredToHeartRate = data.filter { data in
            return data.title == HKQuantityTypeIdentifier.heartRate.rawValue
        }
        let filteredToNight = filteredToHeartRate.filter { data in
            return data.date.get(.hour) >  0 && data.date.get(.hour) <  4
        }
        
        let startDates = filteredToNight.map{$0.date.getFormattedDate(format: "yyyy-MM-dd")}
        let startDateColumn = Column(name: "Start_Date", contents: startDates)
       
        let startTimes = filteredToNight.map{$0.date.getFormattedDate(format: "HH:mm:ss")}
        
        trainingData.append(column: startDateColumn)
        
        let startTimeColumn = Column(name: "Start_Time", contents: startTimes)
        
        trainingData.append(column: startTimeColumn)
        
        let nightlyHeartRateColumn = Column(name: "Heartrate", contents: filteredToNight.map{$0.data})
        trainingData.append(column: nightlyHeartRateColumn)
        
        
        do {
        try trainingData.writeCSV(to: getDocumentsDirectory().appendingPathComponent("A.csv"))
            //print(getDocumentsDirectory().appendingPathComponent("A.csv").dataRepresentation)
        } catch {
            print(error)
            
        }
        completionHandler(true)
    }
    func trainCompareOnDevice(userData: [HealthData], target: String, target2: String, completionHandler: @escaping (ModelResponse) -> Void) {
        var trainingData = DataFrame()
        let filteredToRemoveNan = userData.filter { data in
            return data.data.isNormal && !data.data.isNaN
        }
        let filteredToTarget = filteredToRemoveNan.filter { data in
            return data.type.rawValue == target
        }
        
        let filteredToTarget2 = filteredToRemoveNan.filter { data in
            return data.type.rawValue == target2
        }
        let filteredToTarget3 = filteredToRemoveNan.filter { data in
            return  data.title == target
        }
        
        let filteredToTarget4 = filteredToRemoveNan.filter { data in
            return  data.title == target2
        }
       print(filteredToTarget3)
           print(filteredToTarget2)
           
            
          
                
               // print(trainingData.summary())
        var dataArray = filteredToTarget3.isEmpty ?  filteredToTarget.map{Double($0.data)} : filteredToTarget3.map{Double($0.data)}
        var dataArray2 = filteredToTarget4.isEmpty ?  filteredToTarget2.map{Double($0.data)} : filteredToTarget4.map{Double($0.data)}
        
        var dateArray = filteredToTarget3.isEmpty ?  filteredToTarget.map{$0.date} : filteredToTarget3.map{$0.date}
        var dateArray2 = filteredToTarget4.isEmpty ?  filteredToTarget2.map{$0.date} : filteredToTarget4.map{$0.date}
                print(average(numbers: dataArray))
        let smallestCount = [dataArray.count, dataArray2.count].min() ?? 0
        let largestCount = [dataArray.count, dataArray2.count].max() ?? 0
        if dataArray.count > dataArray2.count {
            dataArray.removeLast(largestCount - smallestCount)
            dateArray.removeLast(largestCount - smallestCount)
        }
        if dataArray.count < dataArray2.count {
            dataArray2.removeLast(largestCount - smallestCount)
            dateArray2.removeLast(largestCount - smallestCount)
        }
        var dateColumn = Column<Date>(name: "Date", capacity: smallestCount)
        var dateColumn2 = Column<Date>(name: "Date", capacity: smallestCount)
        var column = Column<Double>(name: target, capacity: smallestCount)
        
        column.append(contentsOf: dataArray)
        dateColumn.append(contentsOf: dateArray)
        dateColumn2.append(contentsOf: dateArray2)
        var column2 = Column<Double>(name: target2, capacity: smallestCount)
       
     
       
        column2.append(contentsOf: dataArray2)
        
        var targetOneData = DataFrame()
        var targetTwoData = DataFrame()
        
//        trainingData.append(column: dateColumn)
        targetOneData.append(column: column)
        targetOneData.append(column: dateColumn)
        targetTwoData.append(column: column2)
        targetTwoData.append(column: dateColumn2)
        trainingData = targetOneData.joined(targetTwoData, on: "Date")
                    
        print(trainingData.columns.map{$0.name})
//        trainingData = trainingData.grouped(by: "Date", timeUnit: .weekday)
//
//        trainingData = trainingData.grouped(by: "Date", timeUnit: .weekOfYear)
//
//        trainingData = trainingData.grouped(by: "Date", timeUnit: .year)
        let randomSplit = trainingData.randomSplit(by: 0.5)
        //print(randomSplit)
        let testingData = DataFrame(randomSplit.0)
        trainingData = DataFrame(randomSplit.1)
        do {
            let model = try MLRandomForestRegressor(trainingData: trainingData, targetColumn: "left." + target)
           
           // try model.write(to: getDocumentsDirectory().appendingPathComponent(DataType.HappinessScore.rawValue + ".mlmodel"))
            print(model.trainingMetrics)
            print(model.validationMetrics)
            let predictions = try model.predictions(from: testingData)
            print(average(numbers: predictions.map{($0.unsafelyUnwrapped) as! Double}))
            //let testingDataAsDouble =  trainingData.rows.map{$0.map{$0.unsafelyUnwrapped as! Double}}
           var doubleArray = [Double]()
           // for data in testingDataAsDouble {
                //doubleArray.append(contentsOf: data)
           // }
             
            mlData = ModelResponse(type: target, predicted: predictions.map{($0.unsafelyUnwrapped) as! Double}, actual: doubleArray, accuracy: model.trainingMetrics.rootMeanSquaredError)
            completionHandler(mlData)
        } catch {
            print(error)

        }
       

    }
    
    func average(numbers: [Double]) -> Double {
       // print(numbers)
       return Double(numbers.reduce(0,+))/Double(numbers.count)
   }
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
}
#endif
