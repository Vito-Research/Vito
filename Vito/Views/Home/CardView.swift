//
//  CardView.swift
//  CardView
//
//  Created by Andreas on 8/18/21.
//

import SwiftUI

struct CardView: View {
    @State var card: Card
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
                .foregroundColor(Color(UIColor.systemGroupedBackground))
            HStack {
                Image(card.image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                VStack {
                    HStack {
                        Spacer()
                    Text(card.title)
                        .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                        .multilineTextAlignment(.trailing)
                    } .padding(.bottom)
                    HStack {
                        Spacer()
                    Text(card.description)
                        .font(.custom("Poppins", size: 14, relativeTo: .headline))
                        .multilineTextAlignment(.trailing)
                }
                    HStack {
                        Spacer()
                    Button(action: card.action) {
                        Text(card.cta)
                    } .buttonStyle(CTAButtonStyle())
                        
                    }
                } .padding(.trailing)
            } .padding(.vertical)
        }
    }
}

