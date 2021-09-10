//
//  DataTypesListView.swift
//  DataTypesListView
//
//  Created by Andreas on 8/20/21.
//

import SwiftUI

struct DataTypesListView: View {
    @State var explanations = [Explanation(image: .heart, explanation: "Heart Rate"), Explanation(image: .person , explanation: "Steps"), Explanation(image: .sleep, explanation: "Active Energy")] //Explanation(image: .lungs, explanation: "Respiratory Rate"), Explanation(image: .oCircle, explanation: "Oxygen Saturation")]
    @State var descriptions = ["Detects abnormally high heart rate while asleep.", "Used to omit data taken at night while your still active.", "Used to omit data taken at night while your still active."]//, "Monitors for high breathing rates while asleep (only WatchOS 8).", "Detects low oxygen in your blood (only Apple Watch 6)."]
    var body: some View {
        VStack {
            
               
            ForEach(explanations.indices, id:\.self) { i in
                Button(action: {
                    if !(explanations[i].toggle ?? false) {
                        explanations[i].toggle = true
                    } else {
                        explanations[i].toggle = false
                    }
                }) {
                    VStack {
                HStack {
                    
                    Image(systemSymbol: explanations[i].image)
                        .font(.title)
                Text(explanations[i].explanation)
                    .font(.custom("Poppins-Bold", size: 20, relativeTo: .headline))
                    Spacer()
                }
                    if (explanations[i].toggle ?? false) {
                HStack {
                    
                Text(descriptions[i])
                    .font(.custom("Poppins", size: 16, relativeTo: .headline))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top)
                    .multilineTextAlignment(.leading)
                    Spacer()
                }
                    }
                    }
                Divider()
            }
        } .padding()
        }
    }
}

struct DataTypesListView_Previews: PreviewProvider {
    static var previews: some View {
        DataTypesListView()
    }
}
