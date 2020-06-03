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
    public var defaultUnathorizedAccessHandler: (() -> Void)?
    public var errorMapping: (NetworkingError) -> Error = { $0 }

    public var encoder: JSONEncoder = CoreEncoder()
    public var decoder: JSONDecoder = CoreDecoder()

    public init(baseURL: String,
                headerFields: HTTPHeaderFields = [:],
                queryParameters: [URLQueryItem] = [],
                defaultUnathorizedAccessHandler: (() -> Void)? = nil) {

        self.baseURL = baseURL
        self.defaultHeaderFields.custom = headerFields
        self.defaultQueryParameters = queryParameters
        self.defaultUnathorizedAccessHandler = defaultUnathorizedAccessHandler
    }
}
