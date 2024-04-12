//
//  PostsAPI.swift
//
//
//  Created by Tech Alchemy
//

import Foundation

enum PostsAPI: NetworkRequest {

    case fetchPosts
    case createPost(description: String, image: String)
    case like(postId: String, likesCount: Int)

    var path: String {
        switch self {
        case .fetchPosts: return "/v1/post"
        case .createPost: return "/v1/post/create"
        case .like(let postId, _): return "/v1/post/\(postId)"
        }
    }

    var body: Data? {
        switch self {
        case .createPost(let description, let image):
            let json: [String: Any] = ["text": description, "image": image, "likes": 0, "tags": "", "owner": AppConstants.dummyUserID]
            return try? JSONSerialization.data(withJSONObject: json)
        case .like(_, let likesCount):
            let json = ["likes": likesCount]
            return try? JSONSerialization.data(withJSONObject: json)
        default:
            return nil
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchPosts: return .get
        case .createPost: return .post
        case .like: return .put
        }
    }

    var contentType: ContentType {
        return .json
    }
}
