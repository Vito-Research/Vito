//
//  FitbitDara.swift
//  Vito
//
//  Created by Andreas Ink on 3/17/22.
//

import SwiftUI

struct FitbitData: Codable {
    let activitiesHeart: [ActivitiesHeart]

    enum CodingKeys: String, CodingKey {
        case activitiesHeart = "activities-heart"
    }
}

// MARK: - ActivitiesHeart
struct ActivitiesHeart: Codable {
    let dateTime: String
    let value: Value
}

// MARK: - Value
struct Value: Codable {
    let customHeartRateZones, heartRateZones: [HeartRateZone]
    let restingHeartRate: Int
}

// MARK: - HeartRateZone
struct HeartRateZone: Codable {
    let caloriesOut: Double
    let max, min, minutes: Int
    let name: String
}
