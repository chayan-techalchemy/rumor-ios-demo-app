//
//  CreatePostViewModel.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation

protocol CreatePostBusinessLogic {
    func createPost(description: String)
}

class CreatePostViewModel: CreatePostBusinessLogic {

    weak var display: CreatePostDisplayLogic?

    var postsService = PostsService(networkManager: NetworkManager.shared)

    required init(createPostDisplayLogic: CreatePostDisplayLogic?) {
        display = createPostDisplayLogic
    }

    func createPost(description: String) {
        postsService.createPost(description: description, image: AppConstants.dummyPostImages.randomElement() ?? "") { result in
            switch result {
            case .success:
                self.display?.didCreatePost()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
