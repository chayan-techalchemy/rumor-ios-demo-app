//
//  DateExtension.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation

extension Date {
    func getString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
