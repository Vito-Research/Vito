//
//  RedCapData.swift
//  Vito
//
//  Created by Andreas Ink on 3/17/22.
//

import SwiftUI

struct RedCapData: Codable {
    var token: String = ""
    var content: String = "record"
    var action: String = "import"
    var format: String = "csv"
    var type: String = "flat"
    var overwriteBehavior: String = "normal"
    var forceAutoNumber: String = "false"
    var data: String = ""
    var returnContent: String = "count"
    var returnFormat: String = "json"
    
    
}
