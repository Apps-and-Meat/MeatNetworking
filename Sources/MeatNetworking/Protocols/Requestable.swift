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

public struct EmptyResponse: Decodable, Equatable {
    let statusCode: HTTPStatusCode?
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

    func run(configuration: NetworkingConfiguration?,
             authentication: Authentication?,
             retryCount: Int) async throws -> Response

    func run(configuration: NetworkingConfiguration?,
             retryCount: Int) async throws -> Response

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
}

struct MyRequest: Requestable {
    typealias Payload = EmptyPayload
    typealias Response = [String]
}

extension Requestable where Payload == EmptyPayload {
    var parameters: Payload? { nil }
}
