//
//  FeedViewModel.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation

protocol FeedBusinessLogic {
    func fetchPosts()
    func didLikePost(postId: String)
    func didUpdatePost(_ post: Post)
}

class FeedViewModel: FeedBusinessLogic {
    var posts: [Post] = []
    weak var display: FeedDisplayLogic?

    var postsService = PostsService(networkManager: NetworkManager.shared)

    required init(feedDisplayLogic: FeedDisplayLogic?) {
        display = feedDisplayLogic
    }

    func fetchPosts() {
        postsService.fetchPosts { result in
            switch result {
            case .success(let posts):
                self.posts = posts
                self.display?.showFeedData(posts: self.posts)
            case .failure(let error):
                // Handle Error / Show user the error
                self.display?.hideLoader()
                print(error.localizedDescription)
            }
        }
    }

    func didLikePost(postId: String) {
        guard let post = likeUnlikePost(id: postId) else {
            print("Post not found")
            return
        }
        likeUnlikePostAPI(post)
        display?.showFeedData(posts: posts)
    }

    func didUpdatePost(_ post: Post) {
        guard let postIndex = posts.firstIndex(where: { post.id == $0.id }) else {
            print("Post not found")
            return
        }
        posts[postIndex] = post
        display?.showFeedData(posts: posts)
    }

    @discardableResult func likeUnlikePost(id: String) -> Post? {
        guard let postIndex = posts.firstIndex(where: { id == $0.id }) else {
            print("Post not found")
            return nil
        }
        if let isLiked = posts[postIndex].isLiked, isLiked {
            posts[postIndex].likes -= 1
            posts[postIndex].isLiked = false
        } else {
            posts[postIndex].likes += 1
            posts[postIndex].isLiked = true
        }
        return posts[postIndex]
    }

    private func likeUnlikePostAPI(_ post: Post) {
        postsService.likeUnlikePostAPI(post) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                // Reverse the like/unlike in case of an API failure
                self.likeUnlikePost(id: post.id)
                // Handle Error / Show user the error
                print(error.localizedDescription)
            }
        }
    }
}
