//
//  RequestMaker.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public extension Requestable {

    func run() async throws -> Response {
        try await run(retryCount: 0)
    }

    func run(retryCount: Int) async throws -> Response {
        try await run(configuration: nil, retryCount: 0)
    }

    func run(configuration: NetworkingConfiguration?,
             retryCount: Int) async throws -> Response {
        try await run(configuration: configuration, authentication: nil, retryCount: 0)
    }

    func run(configuration: NetworkingConfiguration?,
             authentication: Authentication?,
             retryCount: Int) async throws -> Response {

        let decoder = self.configuration?.decoder ?? configuration?.decoder ?? JSONDecoder()
        let unathorizedHandler = self.configuration?.defaultUnathorizedAccessHandler ?? configuration?.defaultUnathorizedAccessHandler ?? nil
        let errorMapping = self.configuration?.errorMapping ?? configuration?.errorMapping

        do {

            let response: (response: HTTPURLResponse?, data: Data?)
            = try await runRaw(configuration: configuration, authentication: authentication)

            Self.storeCookie(from: response.response)

            // If no data expected just return
            let statusCode = response.response?.status

            if let emptyReponse = EmptyResponse(statusCode: statusCode) as? Response {
                return emptyReponse
            }

            // Check if we have any sessionData else throw nodata error
            guard let validatedSessionData = response.data else {
                throw NetworkingError.notFound
            }

            // If raw Data expected just return sessionData
            if let data = validatedSessionData as? Response {
                return data
            }

            do {
                return try decoder.decode(Response.self, from: validatedSessionData)
            } catch {
                throw NetworkingError(underlyingError: error,
                                      data: validatedSessionData,
                                      statusCode: response.response?.status)
            }

        } catch let error as NetworkingError {
            if logOutIfUnauthorized, error.isUnauthorized, let unathorizedHandler = unathorizedHandler {

                do {
                    let successfulRecover = (try? await unathorizedHandler.recover(retryCount: retryCount)) ?? false

                    if successfulRecover {
                        return try await run(retryCount: retryCount + 1)
                    } else {
                        unathorizedHandler.afterFailedRecover()
                    }
                }
            }
            if let mapError = errorMapping {
                throw mapError(error)
            } else {
                throw error
            }
        }
    }

    func runRaw(configuration: NetworkingConfiguration?,
                authentication: Authentication?) async throws -> (HTTPURLResponse?, Data) {

        let urlReq = try build(configuration: configuration,
                               authentication: authentication)

        let response = try await URLSession.shared.data(for: urlReq)
        let sessionData = response.0
        let sessionResponse = response.1 as? HTTPURLResponse

        if let networkError = NetworkingError(error: nil, response: sessionResponse, data: sessionData) {
            throw networkError
        }
        return (sessionResponse, sessionData)

    }

    private static func storeCookie(from response: HTTPURLResponse?) {
        guard   let url = response?.url,
            let headerFields = response?.allHeaderFields as? [String : String] else {
                return
        }

        if let cookie = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url).first {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }

    func build(configuration: NetworkingConfiguration?,
               authentication: Authentication?) throws ->  URLRequest {

        guard let configuration = self.configuration ?? configuration else {
            throw NetworkingError.badRequest
        }

        guard var url = URL(string: configuration.baseURL)?
            .appendingPathComponent(path)
            .appendingQueryParameters(configuration.defaultQueryParameters)
            else {
                throw NetworkingError.badRequest
        }

        if method.shouldAppendQueryString() {
            url.appendQueryParameters(parameters)
        }

        var urlRequest = URLRequest(url: url)

        if case .none = authentication, requiresAuthentication {
            throw NetworkingError.unauthorized
        }

        // HTTP Method
        urlRequest.addAuthentication(authentication)
        urlRequest.httpMethod = method.rawValue

        // Headers
        headerFields.allFields.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        if let parameters = parameters, method.shouldAddHTTPBody() {
            // Parameters
            switch headerFields.contentType {
            case .json:
                urlRequest.httpBody = try configuration.encoder.encode(parameters)
            case .form:
                urlRequest.httpBody = parameters.percentEscaped().data(using: .utf8)
            }
        }

        return urlRequest
    }
}
