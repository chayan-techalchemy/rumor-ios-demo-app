//
//  Network.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation
import Combine

protocol Network {
    func apiRequest<T: Decodable>(_ request: NetworkRequest, responseType: T.Type) -> Future<T, Error>
}

enum HTTPMethod: String {
    case post, get, delete, put
}

enum ContentType {
    case json
    case none

    func setContentHeader(urlRequest: inout URLRequest) {
        switch self {
        case .json:
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        default:
            break
        }
    }
}

protocol NetworkRequest {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [String: Any]? { get }
    var body: Data? { get }
    var contentType: ContentType { get }
    var requiresAuthHeader: Bool? { get }
}

extension NetworkRequest {
    var queryItems: [String: Any]? { return nil }
    var body: Data? { return nil }
    var contentType: ContentType { return .none }
    var requiresAuthHeader: Bool? { return true }
}

extension NetworkRequest {
    func buildURLRequest(withBaseURL baseURL: URL) -> URLRequest {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))

        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        contentType.setContentHeader(urlRequest: &urlRequest)

        // Generally the logic is: we get the access token from auth API, save it in the Keychain, then we fetch it from Keychain and put it in the Authorization Header, changed it for Mock API purpose
        if requiresAuthHeader == true {
            urlRequest.setValue(AppConstants.dummyAPIAppID, forHTTPHeaderField: "app-id")
        }
        return urlRequest
    }
}
