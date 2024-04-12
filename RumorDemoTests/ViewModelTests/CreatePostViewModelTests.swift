//
//  CreatePostViewModelTests.swift
//  RumorDemoTests
//
//  Created by Tech Alchemy
//

import Foundation

import XCTest
@testable import RumorDemo

final class CreatePostViewModelTests: XCTestCase {

    let createPostViewModel = CreatePostViewModel(createPostDisplayLogic: CreatePostViewController())
    let mockNetwork = MockNetworkManager.shared
    let mockBaseURL = URL(string: "www.mockurl.com/api")!

    override func setUpWithError() throws {
        createPostViewModel.postsService = PostsService(networkManager: mockNetwork)
    }

    override func tearDownWithError() throws {
    }

    func testCreatePostSuccess() throws {
        let path = Bundle(for: type(of: self)).path(forResource: "PostTest", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

        let request = PostsAPI.createPost(description: "Test String", image: "").buildURLRequest(withBaseURL: mockBaseURL)
        mockNetwork.apiResponse = MockNetworkManager.createApiResponse(for: request, statusCode: 200, data: data)

        createPostViewModel.createPost(description: "Test String")

        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            // View Controller gets dismissed in case of success
            XCTAssertTrue(createPostViewModel.display == nil)
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func testCreatePostFailure() throws {
        let request = PostsAPI.createPost(description: "Test String", image: "").buildURLRequest(withBaseURL: mockBaseURL)
        mockNetwork.apiResponse = MockNetworkManager.createApiResponse(for: request, statusCode: 500, data: "Internal Server Error".data(using: .utf8)!)

        createPostViewModel.createPost(description: "Test String")

        let exp = expectation(description: "Test after 0.5 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        if result == XCTWaiter.Result.timedOut {
            // View Controller doesn't get dismissed in case of failure
            XCTAssertTrue(createPostViewModel.display != nil)
        } else {
            XCTFail("Delay interrupted")
        }
    }
}
