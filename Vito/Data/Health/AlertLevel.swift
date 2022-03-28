//
//  AlertLevel.swift
//  Vito
//
//  Created by Andreas Ink on 3/9/22.
//

import Foundation
import Accelerate

@MainActor
struct AlertLevelv3 {
    
    private var state: Level
    
    enum Level {
        case Zero(Alert)
        case One(Alert)
        case Two(Alert)
        case Three(Alert)
        case Four(Alert)
        case Five(Alert)
    }
    struct Alert {
        var clusterCount: Int = 0
        var hr: [Int] = []
        
    }
    
    init() {
        self.state = .Zero(Alert())
    }
    
    func returnAlert() -> Double {
        switch self.state {
        case .Five:
            return 1
            
        default:
            return 0
        }
    }
    
    mutating func calculateMedian(_ hr: Int, _ date: Date?) {
        
        switch self.state {
            
        case .Five(var alert):
            
            alert.hr.append(hr)
            
            if let median = calculateMedian(array: alert.hr.map{Double($0)}) {
                
                if hr >= Int(median) + 4 {
                    
                    alert.clusterCount += 1
                    
                    self.state = .Five(alert)
                    
                } else if hr == Int(median) + 3 {
                    
                    self.state = .Three(Alert(hr: alert.hr))
                } else {
                    self.state = .Zero(Alert(hr: alert.hr))
                }
            }
            
            
            break
        case .Four(var alert):
            
            
            alert.hr.append(hr)
            if let median = calculateMedian(array: alert.hr.map{Double($0)}) {
                
                if hr >= Int(median) + 4 {
                    
                    self.state = .Five(alert)
                    
                } else if hr == Int(median) + 3 {
                    
                    self.state = .Three(Alert(hr: alert.hr))
                } else {
                    
                    self.state = .Zero(Alert(hr: alert.hr))
                }
            }
            
            break
        case .Three(var alert):
            
            alert.hr.append(hr)
            if let median = calculateMedian(array: alert.hr.map{Double($0)}) {
                if hr >= Int(median) + 4 {
                    
                    self.state = .Four(alert)
                    
                } else if hr == Int(median) + 3 {
                    
                    self.state = .Three(Alert(hr: alert.hr))
                } else {
                    
                    self.state = .Zero(Alert(hr: alert.hr))
                }
            }
            
            
            break
            
        case .Two(var alert):
            
            alert.hr.append(hr)
            
            if let median = calculateMedian(array: alert.hr.map{Double($0)}) {
                if hr >= Int(median) + 4 {
                    
                    
                    
                    
                    
                    self.state = .Five(alert)
                    
                } else if hr == Int(median) + 3 {
                    
                    self.state = .Three(Alert(hr: alert.hr))
                } else {
                    
                    
                    self.state = .Zero(Alert(hr: alert.hr))
                }
            }
            
            break
        case .One(var alert):
            
            alert.hr.append(hr)
            if let median = calculateMedian(array: alert.hr.map{Double($0)}) {
                if hr >= Int(median) + 4 {
                    
                    self.state = .Four(alert)
                    
                } else if hr == Int(median) + 3 {
                    
                    self.state = .Three(Alert(hr: alert.hr))
                } else {
                    
                    self.state = .Zero(Alert(hr: alert.hr))
                }
            }
            
            
            break
        case .Zero(var alert):
            
            alert.hr.append(hr)
            
            if let median = calculateMedian(array: alert.hr.map{Double($0)}) {
                if hr >= Int(median) + 4 {
                    
                    self.state = .Two(alert)
                    
                } else if hr == Int(median) + 3 {
                    
                    self.state = .One(Alert(hr: alert.hr))
                } else {
                    
                    self.state = .Zero(Alert(hr: alert.hr))
                }
            } else {
                
                self.state = .Zero(Alert(hr: alert.hr))
            }
            
            
            
        }
        
    }
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
    func average(numbers: [Double]) -> Double {
        // print(numbers)
        return vDSP.mean(numbers)
    }
}
