//
//  Onboarding.swift
//  Onboarding
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import SFSafeSymbols

struct Onboarding: Identifiable, Hashable {
    var id: UUID
    var image: String
    var title: String
    var description: String
    var toggleData = [ToggleData]()
}

struct ToggleData: Identifiable, Hashable {
    var id: UUID
    var toggle: Bool
    var explanation: Explanation
    
}
struct Explanation: Hashable {
    var image: SFSymbol
    var explanation: String
    var detail: String
}
