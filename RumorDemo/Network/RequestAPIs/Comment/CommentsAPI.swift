//
//  CommentsAPI.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation

enum CommentsAPI: NetworkRequest {

    case fetchComments(postId: String)
    case createComment(postId: String, messsage: String)

    var path: String {
        switch self {
        case .fetchComments(let postId): return "/v1/post/\(postId)/comment"
        case .createComment: return "/v1/comment/create"
        }
    }

    var body: Data? {
        switch self {
        case .createComment(let postId, let messsage):
            let json = ["post": postId, "message": messsage, "owner": AppConstants.dummyUserID]
            return try? JSONSerialization.data(withJSONObject: json)
        default:
            return nil
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchComments: return .get
        case .createComment: return .post
        }
    }

    var contentType: ContentType {
        return .json
    }
}
