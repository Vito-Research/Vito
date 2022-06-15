//
//  DataTypesListView.swift
//  DataTypesListView
//
//  Created by Andreas on 8/20/21.
//

//import SwiftUI
//import VitoKit
//struct DataTypesListView: View {
//    @State var toggleData = [ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .heart, explanation: "Heart Rate", detail: "Abnormally high heart rate while asleep can be a sign of distress from your body")), ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .lungs, explanation: "Respiratory Rate", detail: "High respiratory rate while asleep can be a sign of distress from your body")), ToggleData(id: UUID(), toggle: false, explanation:  Explanation(image: .person , explanation: "Steps", detail: "Utilized to detect when you are alseep")), ToggleData(id: UUID(), toggle: false, explanation: Explanation(image: .flame, explanation: "Active Energy", detail: "Utilized to detect when you are alseep"))] //Explanation(image: .lungs, explanation: "Respiratory Rate"), Explanation(image: .oCircle, explanation: "Oxygen Saturation")]
//   //, Explanation(image: .sleep, explanation: "Active Energy"), Explanation(image: .lungs, explanation: "Respiratory Rate")
//   //, "Monitors for high breathing rates while asleep (only WatchOS 8).", "Detects low oxygen in your blood (only Apple Watch 6)."]
//    var body: some View {
//        VStack {
//            
//               
//            ForEach(toggleData.indices, id:\.self) { i in
//                Button(action: {
//                    if !(toggleData[i].toggle) {
//                        toggleData[i].toggle = true
//                    } else {
//                        toggleData[i].toggle = false
//                    }
//                }) {
//                    VStack {
//                HStack {
//                    
//                    Image(systemSymbol: toggleData[i].explanation.image)
//                        .font(.title)
//                    Text(toggleData[i].explanation.explanation)
//                        .multilineTextAlignment(.leading)
//                    .font(.custom("Poppins-Bold", size: 20, relativeTo: .headline))
//                    Spacer()
//                }
//                    if (toggleData[i].toggle) {
//                HStack {
//                    
//                    Text(toggleData[i].explanation.detail)
//                    .font(.custom("Poppins", size: 16, relativeTo: .headline))
//                    .fixedSize(horizontal: false, vertical: true)
//                    .foregroundColor(Color.cyan)
//                    .padding(.top)
//                    .multilineTextAlignment(.leading)
//                    Spacer()
//                }
//                    }
//                    }
//                Divider()
//            }
//        } .padding()
//        }
//    }
//
//
//}
