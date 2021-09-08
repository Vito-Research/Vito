//
//  MLData.swift
//  MLData
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI

struct ModelResponse: Codable {
    var type: String
    var predicted: [Double]
    var actual: [Double]
    var accuracy: Double
}
enum PredictedType: String, Codable, CaseIterable {
    case positive = "+"
    case negitive = "-"
}
