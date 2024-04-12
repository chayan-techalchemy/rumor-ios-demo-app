//
//  StringExtension.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation

extension String {
    func getDateFromString(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}
