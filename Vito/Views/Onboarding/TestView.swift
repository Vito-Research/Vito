//
//  TestView.swift
//  Vito
//
//  Created by Andreas Ink on 6/13/22.
//

import SwiftUI
import VitoKit
import HealthKit

struct TestView: View {
    @StateObject var vito = Vito(selectedTypes: [.Vitals])
    
   
    var body: some View {
        NavigationView {
      
            if vito.autheticated {
                List {
                    Section {
                        ForEach(vito.healthData) { data in
                        Section(data.date.formatted()) {
                           
                        Text("\(data.data)")
                            .font(.headline)
                        Text("\(data.risk)")
                            .font(.largeTitle.bold())
                        
                        }
                    }
                    }
                } .navigationTitle(String("\(vito.healthData.map{$0.risk}.filter{$0 == 1}.count)"))
                    .onAppear() {


                        for type in HKQuantityTypeIdentifier.Vitals {
                            
                            vito.outliers(for: type, unit: type.unit, with: Date().addingTimeInterval(.month * 4), to: Date(), filterToActivity: .active)
                        }
                        
                    }
            } else {
            
                    
            }
          
        }
    }
}

