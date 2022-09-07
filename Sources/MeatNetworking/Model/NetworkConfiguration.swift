//
//  NetworkConfiguration.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public struct NetworkingConfiguration {

    public var baseURL: String
    public var defaultHeaderFields = HeaderFieldList()
    public var defaultQueryParameters: [URLQueryItem]
    public var defaultUnathorizedAccessHandler: UnathorizedAccessHandler?
    public var errorMapping: ((NetworkingError) -> Error)?

    public var encoder: JSONEncoder = CoreEncoder()
    public var decoder: JSONDecoder = CoreDecoder()

    public init(baseURL: String,
                headerFields: HTTPHeaderFields = [:],
                queryParameters: [URLQueryItem] = [],
                defaultUnathorizedAccessHandler: UnathorizedAccessHandler? = nil) {

        self.baseURL = baseURL
        self.defaultHeaderFields.custom = headerFields
        self.defaultQueryParameters = queryParameters
        self.defaultUnathorizedAccessHandler = defaultUnathorizedAccessHandler
    }
}

public protocol UnathorizedAccessHandler {
    func recover(retryCount: Int) async throws -> Bool
    func afterFailedRecover()
}
