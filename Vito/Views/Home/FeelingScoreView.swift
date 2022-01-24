//
//  FeelingScoreView.swift
//  FeelingScoreView
//
//  Created by Andreas on 8/18/21.
//

//import SwiftUI
//
//struct FeelingScoreInputView: View {
//    @ObservedObject var health: HealthV2
//    @State var tapped = false
//    var body: some View {
//        VStack {
//            HStack {
//            Text("Feeling Score")
//                .font(.custom("Poppins-Bold", size: 16, relativeTo: .subheadline))
//                .padding()
//                Spacer()
//            }
//        HStack {
//            if health.tempHealthData.type == .Feeling {
//            ForEach(1...5, id:\.self) { i in
//                Spacer()
//                Button(action: {
//                    withAnimation(.easeOut) {
//                    health.tempHealthData = HealthData(id: UUID().uuidString, type: .Feeling, title: health.tempHealthData.id, text: "", date: Date(), data: Double(i))
//                    health.healthData.append(health.tempHealthData)
//                    tapped = true
//                    }
//                }) {
//                 
//                Text(String(i))
//                    .font(.custom("Poppins-Bold", size: 16, relativeTo: .subheadline))
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(ZStack {
//                        Color.white.clipShape(Circle())
//                        LinearGradient(gradient: Gradient(colors: i < 3 ? [Color("red"), Color("red").opacity(0.7)] : i > 3 ? [Color("green"), Color("green").opacity(0.7)] : [Color("yellow"), Color("yellow").opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing).clipShape(Circle())})
//                
//                } .scaleEffect(tapped ? (health.tempHealthData.data == Double(i) ? 1.5 : 1) : 1)
//            }
//        }
//            Spacer()
//        }
//    }
//    }
//}
//
