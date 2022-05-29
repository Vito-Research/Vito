//
//  StringExt.swift
//  Vito
//
//  Created by Andreas Ink on 5/28/22.
//

import Foundation

extension String {

    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date? {

        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)

        return date

    }
}




