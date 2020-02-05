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
    
    func runRaw() throws -> (HTTPURLResponse?, Data?) {
        return try RequestMaker.performRequest(request: self)
    }
}

public extension Requestable {

    func toFuture() -> Future<Void, Error> {
        Future<Void, Error> { promise in
            DispatchQueue.main.async {
                do {
                    _ = try self.run(expecting: VoidResult.self)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }

    func toFuture<T: Decodable>(expecting: T.Type) -> Future<T, Error> {
        Future<T, Error> { promise in
            DispatchQueue.main.async {
                do {
                    try promise(.success(self.run(expecting: expecting)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    func toFutureRaw() -> Future<(HTTPURLResponse?, Data?), Error> {
        Future<(HTTPURLResponse?, Data?), Error> { promise in
            DispatchQueue.main.async {
                do {
                    try promise(.success(self.runRaw()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
