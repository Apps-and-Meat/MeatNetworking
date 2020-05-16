//
//  NetworkingError.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2020-05-16.
//

import Foundation

struct NetworkingError: Error {
    
    let underlyingError: Error?
    let statusCode: HTTPStatusCode?
    let data: Data?
    
    init?(error: Error?, response: HTTPURLResponse?, data: Data?) {
        self.underlyingError = error
        self.statusCode = response?.status
        self.data = data
        
        switch statusCode?.responseType {
        case .clientError, .serverError:
            break
        default:
            if underlyingError == nil {
                return nil
            }
        }
    }
    
    init(statusCode: HTTPStatusCode) {
        self.underlyingError = nil
        self.statusCode = statusCode
        self.data = nil
    }
    
    init(underlyingError: Error, data: Data?) {
        self.underlyingError = underlyingError
        self.statusCode = nil
        self.data = data
    }
    
    static var unauthorized: NetworkingError {
        self.init(statusCode: .unauthorized)
    }
    
    static var notFound: NetworkingError {
        self.init(statusCode: .notFound)
    }
}

extension NetworkingError {
    var isUnauthorized: Bool {
        return statusCode == .unauthorized
    }
    var isCancelled: Bool {
        underlyingError?._code == URLError.cancelled.rawValue
    }
    var isDecodingError: Bool {
        underlyingError is DecodingError
    }
}
