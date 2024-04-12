//
//  User.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation

struct User: Codable {
    let id: String
    let title: String
    let firstName: String
    let lastName: String
    let picture: String

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
