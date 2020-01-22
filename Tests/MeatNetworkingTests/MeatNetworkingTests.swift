import XCTest
@testable import MeatNetworking

final class MeatNetworkingTests: XCTestCase {
    func testExample() {
        let client = ByggletApiClient()
        do {
            try client.login(username: "861030-1973", password: "0762009702").runSynchronous()
        } catch {
            XCTFail()
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

import Foundation

class ByggletApiClient: APIClient {
    
    override init() {
        var config =  NetworkingConfiguration(baseURL: "https://app.bygglet.com",
                                                          headerFields: [:],
                                                          queryParameters: [],
                                                          defaultUnathorizedAccessHandler: nil,
                                                          defaultUserCredentials: { return nil })
        
        config.defaultHeaderFields.contentType = .form
        APIClient.configuration = config
    }
    
    func login(username: String, password: String) -> FutureVoid {
        FutureVoid {
            try self.method(.post)
                .path(Path.login)
                .parameters(LoginRequestModel(username: username, password: password))
                .run()
        }
    }
    
    struct LoginRequestModel: Codable {
        let username: String
        let password: String
    }
}

enum Path: String, URLPath {
    case login = "Login"
    
    
    var requiresAuthentication: Bool {
        false
    }
    
    var toString: String {
        self.rawValue
    }
}


