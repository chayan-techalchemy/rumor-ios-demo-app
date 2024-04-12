//
//  Post.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation

struct Post: Codable {
    let id: String
    var text: String
    var image: String
    var likes: Int
    let publishDate: String
    let owner: User
    var isLiked: Bool? = false
}
