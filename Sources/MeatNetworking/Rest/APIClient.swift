//
//  APIClient.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

open class APIClient {
    public var authentication: Authentication?
    public var configuration: NetworkingConfiguration
    
    public init(configuration: NetworkingConfiguration, authentication: Authentication? = nil) {
        self.configuration = configuration
        self.authentication = authentication
    }

    public func run<Request: Requestable>(_ request: Request) async throws -> Request.Response {
        try await request
            .appendingConfiguration(configuration)
            .appendingAuthentication(authentication)
            .run()
    }
}
