//
//  Onboarding.swift
//  Onboarding
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import SFSafeSymbols
import VitoKit


struct Onboarding: Identifiable, Hashable {
    var id: UUID
    var image: String
    var title: String
    var description: String
    var toggleData = [ToggleData]()
}

