//
//  DogAPITests.swift
//  
//
//  Created by Karl Söderberg on 2021-12-15.
//

import XCTest
@testable import MeatNetworking

private struct GetAllPayload: Codable {
    let message: [String: [String]]
}

private struct PostPayload: Encodable {
    let message: Message = .init()
    
    struct Message: Encodable {
        let name = "test name"
        let age: Int = 35
    }
}

final class DogAPITests: XCTestCase {
    
    var client: APIClient = APIClient(configuration: .init(baseURL: "https://dog.ceo/api"))
    
    override func setUp() {
        client = APIClient(configuration: .init(baseURL: "https://dog.ceo/api"))
    }
    
    func testGetList() async throws {
        let path = Path(requiresAuthentication: false, toString: "breeds/list/all")
        let payload = try await client.method(.get).path(path).run(expecting: GetAllPayload.self)
        XCTAssertFalse(payload.message.isEmpty)
    }
    
    func testOAuth2Authentication() async throws {
        let path = Path(requiresAuthentication: true, toString: "breeds/list/all")
        client.authentication = .OAuth2("FAKE")
        _ = try await client.method(.get).path(path).run(expecting: GetAllPayload.self)
   }
    
    func testCustomAuthentication() async throws {
        let path = Path(requiresAuthentication: true, toString: "breeds/list/all")
        client.authentication = .custom(.init())
        _ = try await client.method(.get).path(path).run(expecting: GetAllPayload.self)
   }
    
    func testFailMissingAuthentication() async throws {
        let path = Path(requiresAuthentication: true, toString: "breeds/list/all")
        do {
            _ = try await client.method(.get).path(path).run(expecting: GetAllPayload.self)
        } catch let error as NetworkingError {
            XCTAssertEqual(error.statusCode, .unauthorized)
        }
    }
}

private struct Path: URLPath {
    var requiresAuthentication: Bool
    var toString: String
}
