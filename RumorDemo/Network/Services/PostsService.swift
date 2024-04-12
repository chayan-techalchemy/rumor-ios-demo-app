//
//  PostsService.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation
import Combine

class PostsService {

    private var networkManager: Network
    private var cancelBag = Set<AnyCancellable>()

    init(networkManager: Network) {
        self.networkManager = networkManager
    }

    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        networkManager.apiRequest(PostsAPI.fetchPosts, responseType: FeedResponse.self)
            .sink(receiveCompletion: { (subscriberCompletion: Subscribers.Completion<Error>) in
                switch subscriberCompletion {
                case .finished:
                    print("Successfully fetched posts")
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { data in
                completion(.success(data.data))
            })
            .store(in: &cancelBag)
    }

    func createPost(description: String, image: String, completion: @escaping (Result<Post, Error>) -> Void) {
        networkManager.apiRequest(PostsAPI.createPost(description: description, image: image), responseType: Post.self)
            .sink(receiveCompletion: { (subscriberCompletion: Subscribers.Completion<Error>) in
                switch subscriberCompletion {
                case .finished:
                    print("Successfully created post")
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { data in
                completion(.success(data))
            })
            .store(in: &cancelBag)
    }

    func likeUnlikePostAPI(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        networkManager.apiRequest(PostsAPI.like(postId: post.id, likesCount: post.likes), responseType: Post.self)
            .sink(receiveCompletion: { (subscriberCompletion: Subscribers.Completion<Error>) in
                switch subscriberCompletion {
                case .finished:
                    print("Successfully liked/unliked post")
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { _ in
                completion(.success(()))
            })
            .store(in: &cancelBag)
    }
}
