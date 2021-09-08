//
//  Card.swift
//  Card
//
//  Created by Andreas on 8/18/21.
//

import SwiftUI

struct Card {
    var id = UUID()
    var image: String
    var title: String
    var description: String
    var cta: String
    var action: () -> Void {
            return {
               
            }
        }
}
