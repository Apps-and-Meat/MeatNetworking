//
//  NetworkingError.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2020-05-16.
//

import Foundation

public struct NetworkingError: Error {
    
    public let underlyingError: Error?
    public let statusCode: HTTPStatusCode?
    public let data: Data?
    
    init?(error: Error?, response: HTTPURLResponse?, data: Data? = nil) {
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
    
    init(underlyingError: Error, data: Data?, statusCode: HTTPStatusCode?) {
        self.underlyingError = underlyingError
        self.statusCode = statusCode
        self.data = data
    }
    
    static var badRequest: NetworkingError {
        self.init(statusCode: .badRequest)
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
