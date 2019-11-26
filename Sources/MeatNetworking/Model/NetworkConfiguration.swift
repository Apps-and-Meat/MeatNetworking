//
//  NetworkConfiguration.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public struct NetworkingConfiguration {
    public let baseURL: String
    public var defaultHeaderFields = HeaderFields()
    public let defaultQueryParameters: [URLQueryItem]
    public let defaultUserCredentials: () -> UserNetworkCredentials?
    public let defaultUnathorizedAccessHandler: (() -> Void)?

    public var encoder: JSONEncoder = CoreEncoder()
    public var decoder: JSONDecoder = CoreDecoder()

    public init(baseURL: String,
                headerFields: [String: String],
                queryParameters: [URLQueryItem],
                defaultUnathorizedAccessHandler: (() -> Void)?,
                defaultUserCredentials: @escaping () -> UserNetworkCredentials?) {

        self.baseURL = baseURL
        self.defaultHeaderFields.custom = headerFields
        self.defaultQueryParameters = queryParameters
        self.defaultUnathorizedAccessHandler = defaultUnathorizedAccessHandler
        self.defaultUserCredentials = defaultUserCredentials
    }

    func getURL(path: URLPath, credentials: UserNetworkCredentials? = nil) -> URL {
        var url = URL(string: baseURL)!
        url.appendPathComponent(path.toString)
        url.appendQueryParameters(defaultQueryParameters)
        if path.requiresAuthentication, let credentials = credentials ?? defaultUserCredentials() {
            url.appendQueryParameters(credentials.toQueryParameters())
        }
        return url
    }
}
