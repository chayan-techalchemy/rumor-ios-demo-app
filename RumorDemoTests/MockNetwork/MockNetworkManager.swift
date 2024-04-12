//
//  MockNetworkManager.swift
//  RumorDemoTests
//
//  Created by Tech Alchemy
//

import Foundation
import Combine
@testable import RumorDemo

class MockNetworkManager: Network {

    static let shared = MockNetworkManager()

    typealias APIResponse = URLSession.DataTaskPublisher.Output

    private var cancellables = Set<AnyCancellable>()
    var apiResponse: AnyPublisher<APIResponse, URLError>?

    private init() {}

    func apiRequest<T: Decodable>(_ request: NetworkRequest, responseType: T.Type) -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in
            guard let self = self else {
                return promise(.failure(NetworkError.invalidURL))
            }

            apiResponse!
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw NetworkError.responseError
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(error) = completion {
                        switch error {
                        case let decodingError as DecodingError:
                            promise(.failure(decodingError))
                        case let apiError as NetworkError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(NetworkError.unknown))
                        }
                    }
                }, receiveValue: { promise(.success($0)) })
                .store(in: &self.cancellables)
        }
    }

    static func createApiResponse(for request: URLRequest, statusCode: Int, data: Data) -> AnyPublisher<APIResponse, URLError> {
        let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)!
        return Just((data: data, response: response))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
}
