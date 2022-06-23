//
//  FirebaseManager.swift
//  Vito
//
//  Created by Andreas Ink on 6/23/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import VitoKit
class FirebaseManager: ObservableObject {
    
   
    func saveDataToFirebase(_ data: HealthQuery)  {
        Auth.auth().signInAnonymously { authResult, error in
            do {
        let db = Firestore.firestore()
        let docRef = db.collection("Data")
        let _ = try docRef.addDocument(from: data)
            } catch {
            }
            }
    }
}
