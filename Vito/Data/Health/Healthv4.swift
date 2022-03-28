//
//  Healthv4.swift
//  Vito
//
//  Created by Andreas Ink on 3/28/22.
//

import SwiftUI
import HealthKit
import Accelerate
private let store = HKHealthStore()
actor Healthv4 {
    private let anchorKey = "anchorKey"
//    private var anchor: HKQueryAnchor? {
//        get {
//            // If user defaults returns nil, just return it.
//            guard let data = UserDefaults.standard.object(forKey: anchorKey) as? Data else {
//                return nil
//            }
//
//            // Otherwise, unarchive and return the data object.
//            do {
//                return try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
//            } catch {
//                // If an error occurs while unarchiving, log the error and return nil.
//               // logger.error("Unable to unarchive \(data): \(error.localizedDescription)")
//                return nil
//            }
//        }
//        set(newAnchor) {
//            // If the new value is nil, save it.
//            guard let newAnchor = newAnchor else {
//                UserDefaults.standard.set(nil, forKey: anchorKey)
//                return
//            }
//
//            // Otherwise convert the anchor object to Data, and save it in user defaults.
//            do {
//                let data = try NSKeyedArchiver.archivedData(withRootObject: newAnchor, requiringSecureCoding: true)
//                UserDefaults.standard.set(data, forKey: anchorKey)
//            } catch {
//                // If an error occurs while archiving the anchor, just log the error.
//                // the value stored in user defaults is not changed.
//              //  logger.error("Unable to archive \(newAnchor): \(error.localizedDescription)")
//            }
//        }
//    }
    @discardableResult
    public func loadNewDataFromHealthKit(type: HKSampleType, unit: HKUnit, start: Date, end: Date) async throws -> HealthData? {
        
//        guard isAvailable else {
//           // logger.debug("HealthKit is not available on this device.")
//            return false
//        }
        
     //   logger.debug("Loading data from HealthKit")
        
        //do {
        let (samples, deletedSamples, newAnchor) = try await queryHealthKit(type, startDate: start, endDate: end)
            // Update the anchor.
           // self.anchor = newAnchor
        if let quantitySamples = samples?.compactMap({ sample in
            sample as? HKQuantitySample
        }).filter{$0.metadata?["HKMetadataKeyHeartRateMotionContext"] as? NSNumber != 2 }.map{$0.quantity.doubleValue(for: unit)} {
            return HealthData(id: UUID().uuidString, type: .Health, title: type.identifier, text: "", date: start, data: vDSP.mean(quantitySamples))
            } else {
                
            }
            // Convert new caffeine samples into Drink instances.
//            let newDrinks: [Drink]
//            if let samples = samples {
//                newDrinks = self.drinksToAdd(from: samples)
//            } else {
//                newDrinks = []
//            }
            
            // Create a set of UUIDs for any samples deleted from HealthKit.
//            let deletedDrinks = self.drinksToDelete(from: deletedSamples ?? [])
//
//            // Update the data on the main queue.
//
//            await model?.updateModel(newDrinks: newDrinks, deletedDrinks: deletedDrinks)
//            return true
//        } catch {
//            self.logger.error("An error occurred while querying for samples: \(error.localizedDescription)")
//            return false
//        }
     //   }
        return nil
    }
     func queryHealthKit(_ type: HKSampleType, startDate: Date, endDate: Date) async throws -> ([HKSample]?, [HKDeletedObject]?, HKQueryAnchor?) {
        return try await withCheckedThrowingContinuation { continuation in
            // Create a predicate that only returns samples created within the last 24 hours.
          
            let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
            
            // Create the query.
            let query = HKAnchoredObjectQuery(
                type: type,
                predicate: datePredicate,
                anchor: nil,
                limit: HKObjectQueryNoLimit) { (_, samples, deletedSamples, newAnchor, error) in
                print(samples)
                // When the query ends, check for errors.
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (samples, deletedSamples, newAnchor))
                }
                
            }
            store.execute(query)
        }
    }
}
