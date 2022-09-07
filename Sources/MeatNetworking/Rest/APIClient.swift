//
//  APIClient.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

open class APIClient {
    public var authentication: Authentication? = nil
    public var configuration: NetworkingConfiguration
    
    public init(configuration: NetworkingConfiguration) {
        self.configuration = configuration
    }

    func run<Request: Requestable>(_ request: Request) async throws -> Request.Response {
        return try await request.run(configuration: configuration,
                                     authentication: authentication, retryCount: 0)
    }
}
