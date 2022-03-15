//
//  Fitbit.swift
//  Vito
//
//  Created by Andreas Ink on 3/15/22.
//

import Foundation

class Fitbit: ObservableObject {
    
    var session = URLSession.shared
    @Published var accessToken: String?
    init() {
//        Task {
//            let res = (try await authorize(Data(), to: URL(string: "https://www.fitbit.com/oauth2/authorize?response_type=token&client_id=2389P9&redirect_uri=https%3A%2F%2Fandreasink.web.app&scope=heartrate%20sleep&expires_in=604800")!, type: "GET"))
//            print(res.1)
//            print(String(data: res.0, encoding: .utf8))
//            print(try await getHeartrate())
//           
//        }
    }
    func getHeartrate() async throws -> (Data, URLResponse)? {
        if let accessToken = accessToken {
            
            var request = URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/activities/heart/date/today/1d.json")!)
   //
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        
            return try await session.upload(
                 for: request,
                 from: Data()
                    
             )
        }
        return nil
    //
    }
    func authorize(_ data: Data, to url: URL, type: String = "POST") async throws -> (Data, URLResponse)  {
        var request = URLRequest(url: url)
   //
        
        return try await session.upload(
             for: request,
             from: data
                
         )
    }

}
