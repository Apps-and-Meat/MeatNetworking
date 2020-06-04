//
//  Requestable.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation
import Combine

public typealias HTTPHeaderFields = [String: String?]
public typealias Parameters = [String : Any]

public protocol Requestable {
    var configuration: NetworkingConfiguration { get }
    var method: HTTPMethod { get }
    var path: URLPath { get }
    var parameters: Parameters? { get }
    var authentication: Authentication { get }
    var headerFields: HeaderFieldList { get }
    var logOutIfUnauthorized: Bool { get }
    
    func setIsRunning(_ running: Bool)

    func run() -> Future<VoidResult, NetworkingError>
    func run<T: Decodable>(expecting: T.Type) -> Future<T, NetworkingError>
}

public extension Requestable {

//    func run() throws {
//        _ = try run(expecting: VoidResult.self)
//    }
    
    func run() -> Future<VoidResult, NetworkingError> {
        run(expecting: VoidResult.self)
    }

    func run<T: Decodable>(expecting: T.Type) -> Future<T, NetworkingError> {
        return RequestMaker.performRequest(request: self, expecting: expecting)
    }
    
    func runRaw() -> Future<(HTTPURLResponse?, Data?), NetworkingError> {
        return RequestMaker.performRequest(request: self)
    }
}

extension Requestable {
    
    func build() throws ->  URLRequest {
        
        guard var url = URL(string: configuration.baseURL)?
            .appendingPathComponent(path.toString)
            .appendingQueryParameters(configuration.defaultQueryParameters)
            else {
                throw NetworkingError.badRequest
        }
        
        if method.shouldAppendQueryString() {
            url.appendQueryParameters(parameters)
        }
        
        var urlRequest = URLRequest(url: url)
        
        if case .none = authentication, path.requiresAuthentication {
            throw NetworkingError.unauthorized
        }
        
        // HTTP Method
        urlRequest.addAuthentication(authentication)
        urlRequest.httpMethod = method.rawValue
        
        // Headers
        headerFields.allFields.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        
        if let parameters = parameters, method.shouldAddHTTPBody() {
            // Parameters
            switch headerFields.contentType {
            case .json:
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            case .form:
                urlRequest.httpBody = parameters.percentEscaped().data(using: .utf8)
            }
        }
        
        return urlRequest
    }
}
