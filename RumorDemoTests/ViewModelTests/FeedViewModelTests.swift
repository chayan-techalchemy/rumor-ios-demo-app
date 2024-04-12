//
//  FeedViewModelTests.swift
//  RumorDemoTests
//
//  Created by Tech Alchemy
//

import XCTest
@testable import RumorDemo

final class FeedViewModelTests: XCTestCase {

    let feedViewModel = FeedViewModel(feedDisplayLogic: nil)
    let mockNetwork = MockNetworkManager.shared
    let mockBaseURL = URL(string: "www.mockurl.com/api")!

    override func setUpWithError() throws {
        feedViewModel.postsService = PostsService(networkManager: mockNetwork)
        feedViewModel.posts = []
    }

    override func tearDownWithError() throws {
    }

    func testFetchedPostsCount() throws {
        let path = Bundle(for: type(of: self)).path(forResource: "PostsTest", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let request = PostsAPI.fetchPosts.buildURLRequest(withBaseURL: mockBaseURL)
        mockNetwork.apiResponse = MockNetworkManager.createApiResponse(for: request, statusCode: 200, data: data)

        XCTAssertEqual(feedViewModel.posts.count, 0)

        feedViewModel.fetchPosts()

        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(feedViewModel.posts.count, 20)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func testErrorWhenDecodingFails() throws {
        let path = Bundle(for: type(of: self)).path(forResource: "CommentsTest", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let request = PostsAPI.fetchPosts.buildURLRequest(withBaseURL: mockBaseURL)
        mockNetwork.apiResponse = MockNetworkManager.createApiResponse(for: request, statusCode: 200, data: data)

        XCTAssertEqual(feedViewModel.posts.count, 0)

        feedViewModel.fetchPosts()

        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(feedViewModel.posts.count, 0)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func testPostLikeUnlike() throws {
        createPostsData()

        feedViewModel.likeUnlikePost(id: feedViewModel.posts.first!.id)
        XCTAssertEqual(feedViewModel.posts.first?.isLiked, true)
        XCTAssertEqual(feedViewModel.posts.first?.likes, 3)

        feedViewModel.likeUnlikePost(id: feedViewModel.posts.first!.id)
        XCTAssertEqual(feedViewModel.posts.first?.isLiked, false)
        XCTAssertEqual(feedViewModel.posts.first?.likes, 2)
    }

    func testPostLikeWithAPISuccess() throws {
        createPostsData()

        let path = Bundle(for: type(of: self)).path(forResource: "PostTest", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let request = PostsAPI.fetchPosts.buildURLRequest(withBaseURL: mockBaseURL)
        mockNetwork.apiResponse = MockNetworkManager.createApiResponse(for: request, statusCode: 200, data: data)

        feedViewModel.didLikePost(postId: feedViewModel.posts.first!.id)
        XCTAssertEqual(feedViewModel.posts.first?.isLiked, true)
        XCTAssertEqual(feedViewModel.posts.first?.likes, 3)

        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(feedViewModel.posts.first?.isLiked, true)
            XCTAssertEqual(feedViewModel.posts.first?.likes, 3)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func testPostLikeWithAPIFailure() throws {
        createPostsData()

        let request = PostsAPI.fetchPosts.buildURLRequest(withBaseURL: mockBaseURL)
        mockNetwork.apiResponse = MockNetworkManager.createApiResponse(for: request, statusCode: 500, data: "Internal Server Error".data(using: .utf8)!)

        feedViewModel.didLikePost(postId: feedViewModel.posts.first!.id)
        XCTAssertEqual(feedViewModel.posts.first?.isLiked, true)
        XCTAssertEqual(feedViewModel.posts.first?.likes, 3)

        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(feedViewModel.posts.first?.isLiked, false)
            XCTAssertEqual(feedViewModel.posts.first?.likes, 2)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    private func createPostsData() {
        for index in 0..<10 {
            let owner = User(id: "\(index + 123)", title: "mr", firstName: "John", lastName: "Doe", picture: "")
            feedViewModel.posts.append(Post(id: "\(index + 1)", text: "Test", image: "", likes: 2, publishDate: "", owner: owner))
        }
    }
}
