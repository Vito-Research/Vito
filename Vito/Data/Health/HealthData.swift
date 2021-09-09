//
//  HealthData.swift
//  HealthData
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import SFSafeSymbols
struct HealthData: Identifiable, Codable, Hashable {
    var id: String
    var type: DataType
    var title: String
    var text: String
    var date: Date
    var data: Double

    
    
}
enum DataType: String, Codable, CaseIterable {
    case HRV = "HRV"
    case Health = "Health"
    case Feeling = "Feeling"
    case Risk = "Risk"
}

struct CodableRisk: Identifiable, Codable, Hashable {
    var id: String
    var date: Date
    var risk: CGFloat
    var explanation: [String]
}
struct Risk: Hashable {
    var id: String
    var risk: CGFloat
    var explanation: [Explanation]
}
struct Explanation: Hashable {
    var image: SFSymbol
    var explanation: String
    var toggle: Bool?
}

enum DayOfWeek: Int, Codable, CaseIterable  {
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thursday = 5
    case Friday = 6
    case Saturday = 7
    case Sunday = 1
}
struct Query: Hashable {
    var id: String
    var durationType: DurationType
    var duration: Double
    var anchorDate: Date
}
enum DurationType: String, Codable, CaseIterable  {
    case Day = "Day"
    case Week = "Week"
    case Month = "Month"
    case Year = "Year"
   
}
