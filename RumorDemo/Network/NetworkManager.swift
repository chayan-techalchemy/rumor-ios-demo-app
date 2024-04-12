//
//  NetworkManager.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation
import Combine

class NetworkManager: Network {
    static let shared = NetworkManager()

    private init() {}
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = URL(string: AppConstants.baseURL)!

    func apiRequest<T: Decodable>(_ request: NetworkRequest, responseType: T.Type) -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in
            guard let self = self else {
                return promise(.failure(NetworkError.invalidURL))
            }

            let urlRequest = request.buildURLRequest(withBaseURL: baseURL)

            URLSession.shared.dataTaskPublisher(for: urlRequest)
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
}
