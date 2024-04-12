//
//  PostDetailViewModelTests.swift
//  RumorDemoTests
//
//  Created by Tech Alchemy
//

import XCTest
@testable import RumorDemo

final class PostDetailViewModelTests: XCTestCase {

    let postDetailViewModel = PostDetailViewModel(postDetailDisplayLogic: nil)
    let mockNetwork = MockNetworkManager.shared
    let mockBaseURL = URL(string: "www.mockurl.com/api")!

    override func setUpWithError() throws {
        let owner = User(id: "123", title: "mr", firstName: "John", lastName: "Doe", picture: "")
        postDetailViewModel.postsService = PostsService(networkManager: mockNetwork)
        postDetailViewModel.post = Post(id: "1", text: "Test", image: "", likes: 5, publishDate: "", owner: owner)
        postDetailViewModel.commentsService = CommentsService(networkManager: mockNetwork)
        postDetailViewModel.comments = []
    }

    override func tearDownWithError() throws {
    }

    func testFetchedCommentsCount() throws {
        let path = Bundle(for: type(of: self)).path(forResource: "CommentsTest", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let request = CommentsAPI.fetchComments(postId: "60d21b8667d0d8992e610d3f").buildURLRequest(withBaseURL: mockBaseURL)
        mockNetwork.apiResponse = MockNetworkManager.createApiResponse(for: request, statusCode: 200, data: data)

        XCTAssertEqual(postDetailViewModel.comments.count, 0)

        postDetailViewModel.fetchPostAndComments()

        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(postDetailViewModel.comments.count, 5)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func testErrorWhenDecodingFails() throws {
        let path = Bundle(for: type(of: self)).path(forResource: "PostsTest", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let request = CommentsAPI.fetchComments(postId: "60d21b8667d0d8992e610d3f").buildURLRequest(withBaseURL: mockBaseURL)
        mockNetwork.apiResponse = MockNetworkManager.createApiResponse(for: request, statusCode: 200, data: data)

        XCTAssertEqual(postDetailViewModel.comments.count, 0)

        postDetailViewModel.fetchPostAndComments()

        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(postDetailViewModel.comments.count, 0)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func testAddCommentSuccessAndInsertionAtFirstIndex() throws {
        createCommentsData()
        let message = "This is an excellent picture…"
        let path = Bundle(for: type(of: self)).path(forResource: "CommentTest", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let request = CommentsAPI.createComment(postId: "60d21b8667d0d8992e610d3f", messsage: message).buildURLRequest(withBaseURL: mockBaseURL)
        mockNetwork.apiResponse = MockNetworkManager.createApiResponse(for: request, statusCode: 200, data: data)

        XCTAssertEqual(postDetailViewModel.comments.count, 5)

        postDetailViewModel.addNewComment(message: message)

        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(postDetailViewModel.comments.first!.message, message)
            XCTAssertEqual(postDetailViewModel.comments.count, 6)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func testPostLikeUnlike() throws {
        createPostData()

        postDetailViewModel.likeUnlikePost()
        XCTAssertEqual(postDetailViewModel.post?.isLiked, true)
        XCTAssertEqual(postDetailViewModel.post?.likes, 3)

        postDetailViewModel.likeUnlikePost()
        XCTAssertEqual(postDetailViewModel.post?.isLiked, false)
        XCTAssertEqual(postDetailViewModel.post?.likes, 2)
    }

    func testPostLikeWithAPISuccess() throws {
        createPostData()

        let path = Bundle(for: type(of: self)).path(forResource: "PostTest", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let request = PostsAPI.fetchPosts.buildURLRequest(withBaseURL: mockBaseURL)
        mockNetwork.apiResponse = MockNetworkManager.createApiResponse(for: request, statusCode: 200, data: data)

        postDetailViewModel.didLikePost()
        XCTAssertEqual(postDetailViewModel.post?.isLiked, true)
        XCTAssertEqual(postDetailViewModel.post?.likes, 3)

        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(postDetailViewModel.post?.isLiked, true)
            XCTAssertEqual(postDetailViewModel.post?.likes, 3)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func testPostLikeWithAPIFailure() throws {
        createPostData()

        let request = PostsAPI.fetchPosts.buildURLRequest(withBaseURL: mockBaseURL)
        mockNetwork.apiResponse = MockNetworkManager.createApiResponse(for: request, statusCode: 500, data: "Internal Server Error".data(using: .utf8)!)

        postDetailViewModel.didLikePost()
        XCTAssertEqual(postDetailViewModel.post?.isLiked, true)
        XCTAssertEqual(postDetailViewModel.post?.likes, 3)

        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(postDetailViewModel.post?.isLiked, false)
            XCTAssertEqual(postDetailViewModel.post?.likes, 2)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    private func createCommentsData() {
        for index in 0..<5 {
            let owner = User(id: "\(index + 123)", title: "mr", firstName: "John", lastName: "Doe", picture: "")
            postDetailViewModel.comments.append(Comment(id: "\(index)", message: "A different message", owner: owner, postId: "789", publishDate: ""))
        }
    }

    private func createPostData() {
        let owner = User(id: "123", title: "mr", firstName: "John", lastName: "Doe", picture: "")
        postDetailViewModel.post = Post(id: "1", text: "Test", image: "", likes: 2, publishDate: "", owner: owner)
    }
}
