//
//  CTAButtonStyle.swift
//  CTAButtonStyle
//
//  Created by Andreas on 8/18/21.
//

import SwiftUI

struct CTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
            .foregroundColor(.white)
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).foregroundColor(Color("blue")))
            .scaleEffect(configuration.isPressed ? 1.1 : 1)
            //.animation(.easeOut(duration: 0.2))
    }
}
