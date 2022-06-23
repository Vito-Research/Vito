//
//  ContextView.swift
//  Vito
//
//  Created by Andreas Ink on 6/23/22.
//

import SwiftUI
import SFSafeSymbols

struct ContextView: View {
    let context = [ContextData(title: "Infection", icon: "🤒"), ContextData(title: "Intense Exercise", icon: "🏋️‍♂️"), ContextData(title: "Intense Stress", icon: "😥"), ContextData(title: "Lack of Sleep", icon: "😴")]
    @Binding var contextStr: String
   
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
        HStack {
        ForEach(context, id: \.title) { context in
            ContextCell(context: context, contextStr: $contextStr)
            Spacer()
        }
        } 
        }
    }
}
struct ContextCell: View {
    @State var context: ContextData
    @Binding var contextStr: String
    @State var tapped = false
    var body: some View {
        VStack {
        ZStack {
            Circle()
                .foregroundColor(.accentColor)
            Text(context.icon)
                .font(.custom("Poppins-Bold", size: 60, relativeTo: .headline))
        } .scaleEffect(tapped ? 1 : 0.6)
            Text(context.title)
                .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
        } .padding(.horizontal)
        .onTapGesture {
            withAnimation(Animation.timingCurve(0.85, 0, 0.15, 1, duration: 1.3)) {
            
            tapped = true
            if contextStr != "TEST" {
                contextStr = context.title
            }
            }
        }
        .onAppear() {
            if contextStr == context.title {
                withAnimation(Animation.timingCurve(0.85, 0, 0.15, 1, duration: 1.3)) {
                
                tapped = true
                 
                }
            }
        }
    }
}
struct ContextData {
    var title: String
    var icon: String
   
}
