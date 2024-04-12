//
//  NetworkError.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidData
    case responseError
    case unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("invalid_url", comment: "Invalid URL")
        case .invalidData:
            return NSLocalizedString("invalid_data", comment: "Invalid Data")
        case .responseError:
            return NSLocalizedString("unexpected_status_code", comment: "Unexpected status code")
        case .unknown:
            return NSLocalizedString("unknown_error", comment: "Unknown error")
        }
    }
}
