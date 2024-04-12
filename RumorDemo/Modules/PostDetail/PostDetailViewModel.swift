//
//  PostDetailViewModel.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation

protocol PostDetailBusinessLogic {
    func didLikePost()
    func fetchPostAndComments()
    func addNewComment(message: String)
}

protocol PostDetailDataPassing {
    var post: Post? { get set }
}

class PostDetailViewModel: PostDetailBusinessLogic, PostDetailDataPassing {
    var post: Post?
    var comments: [Comment] = []

    private weak var display: PostDetailDisplayLogic?

    var postsService = PostsService(networkManager: NetworkManager.shared)
    var commentsService = CommentsService(networkManager: NetworkManager.shared)

    required init(postDetailDisplayLogic: PostDetailDisplayLogic?) {
        display = postDetailDisplayLogic
    }

    func didLikePost() {
        guard let post = post else {
            print("Post not found")
            return
        }
        let updatedPost = likeUnlikePost()
        likeUnlikePostAPI(post)
        display?.refreshPost(updatedPost ?? post)
    }

    func fetchPostAndComments() {
        guard let post = post else {
            print("Post not found")
            return
        }
        display?.refreshPost(post)
        commentsService.fetchComments(postId: post.id) { result in
            switch result {
            case .success(let comments):
                self.comments = comments
                self.display?.refreshComments(comments)
            case .failure(let error):
                self.display?.hideLoader()
                print(error.localizedDescription)
            }
        }
    }

    func addNewComment(message: String) {
        guard let post = post else {
            print("Post not found")
            return
        }
        commentsService.createComment(postId: post.id, message: message) { result in
            switch result {
            case .success(let comment):
                self.comments.insert(comment, at: 0)
                self.display?.refreshComments(self.comments)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    @discardableResult func likeUnlikePost() -> Post? {
        if let isLiked = post?.isLiked, isLiked {
            post?.likes -= 1
            post?.isLiked = false
        } else {
            post?.likes += 1
            post?.isLiked = true
        }
        return post
    }

    private func likeUnlikePostAPI(_ post: Post) {
        postsService.likeUnlikePostAPI(post) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                // Reverse the like/unlike in case of an API failure
                self.likeUnlikePost()
                // Handle Error / Show user the error
                print(error.localizedDescription)
            }
        }
    }
}
