//
//  Comment.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation

struct Comment: Codable {
    let id: String
    let message: String
    let owner: User
    let postId: String
    let publishDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case owner
        case postId = "post"
        case publishDate
    }
}
