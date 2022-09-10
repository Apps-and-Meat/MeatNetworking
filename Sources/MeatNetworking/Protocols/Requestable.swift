//
//  Requestable.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public typealias HTTPHeaderFields = [String: String?]
public typealias Parameters = [String : Any]

public struct RawResponse: Decodable, Equatable {
    public var statusCode: HTTPStatusCode? { urlResponse.status }
    public let urlResponse: HTTPURLResponse
    public let data: Data?

    public init(httpUrlResponse: HTTPURLResponse, data: Data? = nil) {
        self.urlResponse  = httpUrlResponse
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        throw NetworkingError.notFound
    }
}

public struct EmptyPayload: Encodable { }

public protocol Requestable {
    associatedtype Payload: Encodable
    associatedtype Response: Decodable
    
    var configuration: NetworkingConfiguration? { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Payload? { get }
    var authentication: Authentication? { get }
    var headerFields: HeaderFieldList { get }
    var logOutIfUnauthorized: Bool { get }
    var requiresAuthentication: Bool { get }

    func run(retryCount: Int) async throws -> Response

    func run() async throws -> Response
}

public extension Requestable {
    var headerFields: HeaderFieldList { .init() }
    var logOutIfUnauthorized: Bool { false }
    var requiresAuthentication: Bool { false }
    var path: String { return "" }
    var method: HTTPMethod { .get }
    var authentication: Authentication? { nil }
    var configuration: NetworkingConfiguration? { nil }

    func appendingAuthentication(_ auth: Authentication?) -> AuthAndConfigAppendedRequest<Payload, Response> {
        AuthAndConfigAppendedRequest(configuration: configuration,
                                     method: method,
                                     path: path,
                                     parameters: parameters,
                                     authentication: authentication ?? auth,
                                     headerFields: headerFields,
                                     logOutIfUnauthorized: logOutIfUnauthorized,
                                     requiresAuthentication: requiresAuthentication)
    }

    func appendingConfiguration(_ config: NetworkingConfiguration) -> AuthAndConfigAppendedRequest<Payload, Response> {
        AuthAndConfigAppendedRequest(configuration: configuration ?? config,
                                     method: method,
                                     path: path,
                                     parameters: parameters,
                                     authentication: authentication,
                                     headerFields: headerFields,
                                     logOutIfUnauthorized: logOutIfUnauthorized,
                                     requiresAuthentication: requiresAuthentication)
    }
}

public struct AuthAndConfigAppendedRequest<Payload: Encodable, Response: Decodable>: Requestable {
    public typealias Payload = Payload
    public typealias Response = Response

    public var configuration: NetworkingConfiguration?
    public var method: HTTPMethod
    public var path: String
    public var parameters: Payload?
    public var authentication: Authentication?
    public var headerFields: HeaderFieldList
    public var logOutIfUnauthorized: Bool
    public var requiresAuthentication: Bool
}

extension Requestable where Payload == EmptyPayload {
    public var parameters: Payload? { nil }
}
