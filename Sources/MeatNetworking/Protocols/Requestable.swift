//
//  Requestable.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public typealias HTTPHeaderType = [String: String?]
public typealias Parameters = [String : Any]

public protocol Requestable {
    var configuration: NetworkingConfiguration { get }
    var method: HTTPMethod { get }
    var path: URLPath { get }
    var parameters: Parameters? { get }
    var credentials: UserNetworkCredentials? { get }
    var headerFields: HeaderFields { get }
    var logOutIfUnauthorized: Bool { get }
    
    func setIsRunning(_ running: Bool)

    func run() throws
    func run<T: Decodable>(expecting: T.Type) throws -> T
}

public extension Requestable {

    func run() throws {
        _ = try run(expecting: VoidResult.self)
    }

    func run<T: Decodable>(expecting: T.Type) throws -> T {
        return try RequestMaker.performRequest(request: self, expecting: expecting)
    }
}
