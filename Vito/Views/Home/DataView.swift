////
////  DataView.swift
////  DataView
////
////  Created by Andreas on 8/18/21.
////
//
import SwiftUI

struct DataView: View {
    @State private var date = Date()
    @State private var average = 0.0
    @ObservedObject var health: Health
    @State var data = ChartData(values: [("", 0.0)])
    var body: some View {
        
        VStack {
            HStack {
                Text("Average: " + String(average))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
                .onAppear() {
                    loadData  { (score) in
                        average = health.average(numbers: health.codableRisk.map{Double($0.risk)})
                        
                    }
                    let maximum =  ChartData(values: [("", 0.0)])
                    let filtered2 = data.points.filter { word in
                        return word.0 != "NA"
                    }
                   
                    let average2 = health.average(numbers: filtered2.map {$0.1})
                    let minScore = filtered2.map {$0.1}.max()
                    let filtered = filtered2.filter { word in
                        return word.1 == minScore
                    }
                    
                    if average2.isNormal {
                        maximum.points.append((String("Average"), average2))
                        maximum.points.append((String(filtered.last?.0 ?? "") , filtered.last?.1 ?? 0.0))

                    }

                }
            
            }
                //.opacity(isTutorial ? (tutorialNum == 1 ? 1.0 : 0.1) : 1.0)
                .onChange(of: date, perform: { value in
                    
                    //refresh = true
                    loadData  { (score) in
                        average = health.average(numbers: health.codableRisk.map{Double($0.risk)})
                        
                    }
                    let maximum =  ChartData(values: [("", 0.0)])
                   
                    let filtered2 = data.points.filter { word in
                        return word.0 != "NA"
                    }
                   
                    let average2 = health.average(numbers: filtered2.map {$0.1})
                    let minScore = filtered2.map {$0.1}.max()
                    let filtered = filtered2.filter { word in
                        return word.1 == minScore
                    }
                    
                    if average2.isNormal {
                        maximum.points.append((String("Average"), average2))
                        maximum.points.append((String(filtered.last?.0 ?? "") , filtered.last?.1 ?? 0.0))
                     
                    }
                })
            HStack {
                Text("Total Score")
                    .font(.custom("Poppins-Bold", size: 24, relativeTo: .headline))
                Spacer()
            }  //.opacity(isTutorial ? (tutorialNum == 2 ? 1.0 : 0.1) : 1.0)
            
                
          
//            Text("1 indicates poorer health while a 0 indicates a healthier condition")
//                .fixedSize(horizontal: false, vertical: true)
//                .multilineTextAlignment(.leading)
//                .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                //.opacity(isTutorial ? (tutorialNum == 2 ? 1.0 : 0.1) : 1.0)
            
//            if max.points.last?.1 != max.points.first?.1 {
//                DayChartView(title: "Score", chartData: $max, refresh: $refresh, dataTypes: $dataTypes, userData: $userData)
//                Text(maxText)
//                    .multilineTextAlignment(.leading)
//                    .fixedSize(horizontal: false, vertical: true)
//                    .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
//            }
            
           
            Spacer()
        } .padding()
           
        }
    
    func loadData( completionHandler: @escaping (String) -> Void) {
       
        data = ChartData(values: [("", 0.0)])
        
        
        let filtered = health.codableRisk.filter { data in
            return data.date.get(.weekOfYear) == date.get(.weekOfYear) && date.get(.year) == data.date.get(.year)
        }
        print(filtered)
        let scorePoints = ChartData(values: [("", 0.0)])
        
        for day in 1...7 {
            
       
            let filteredDay = filtered.filter { data in
               
                return data.date.get(.weekday) == day
            }
            
            
            let averageScore =  health.average(numbers: filteredDay.map{$0.risk})
           
            scorePoints.points.append(("\(DayOfWeek(rawValue: day) ?? .Monday)", averageScore))
            
            
           
           
 
            self.data = scorePoints
        
        }
    }
    }

