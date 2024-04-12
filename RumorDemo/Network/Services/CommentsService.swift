//
//  CommentsService.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation
import Combine

class CommentsService {

    private var networkManager: Network
    private var cancelBag = Set<AnyCancellable>()

    init(networkManager: Network) {
        self.networkManager = networkManager
    }

    func fetchComments(postId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        networkManager.apiRequest(CommentsAPI.fetchComments(postId: postId), responseType: CommentResponse.self)
            .sink(receiveCompletion: { (subscriberCompletion: Subscribers.Completion<Error>) in
                switch subscriberCompletion {
                case .finished:
                    print("Successfully fetched comments")
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { data in
                completion(.success(data.data))
            })
            .store(in: &cancelBag)
    }

    func createComment(postId: String, message: String, completion: @escaping (Result<Comment, Error>) -> Void) {
        networkManager.apiRequest(CommentsAPI.createComment(postId: postId, messsage: message), responseType: Comment.self)
            .sink(receiveCompletion: { (subscriberCompletion: Subscribers.Completion<Error>) in
                switch subscriberCompletion {
                case .finished:
                    print("Successfully created comment")
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { data in
                completion(.success(data))
            })
            .store(in: &cancelBag)
    }
}
