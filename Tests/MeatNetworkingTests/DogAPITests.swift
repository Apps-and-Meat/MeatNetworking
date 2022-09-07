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


    private struct GetListRequest: Requestable {
        typealias Payload = EmptyPayload
        typealias Response = GetAllPayload
        var path: String = "breeds/list/all"
        var method: HTTPMethod = .get
    }

    func testGetList() async throws {
        let payload = try await client.run(GetListRequest())
        XCTAssertFalse(payload.message.isEmpty)
    }

    private struct AuthTestRequest: Requestable {
        typealias Payload = EmptyPayload
        typealias Response = GetAllPayload
        var path: String = "breeds/list/all"
        var method: HTTPMethod = .get
        var requiresAuthentication: Bool = true
    }
    
    func testOAuth2Authentication() async throws {
        client.authentication = .OAuth2("FAKE")
        _ = try await client.run(AuthTestRequest())
   }
    
    func testCustomAuthentication() async throws {
        client.authentication = .custom(.init())
        _ = try await client.run(AuthTestRequest())
   }
    
    func testFailMissingAuthentication() async throws {
        do {
            _ = try await client.run(AuthTestRequest())
        } catch let error as NetworkingError {
            XCTAssertEqual(error.statusCode, .unauthorized)
        }
    }
}

private struct Path: URLPath {
    var requiresAuthentication: Bool
    var toString: String
}
