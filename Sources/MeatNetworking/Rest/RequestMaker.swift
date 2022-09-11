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

        let decoder = self.configuration?.decoder ?? JSONDecoder()
        let unathorizedHandler = self.configuration?.defaultUnathorizedAccessHandler
        let errorMapping = self.configuration?.errorMapping

        do {

            let response: (response: HTTPURLResponse?, data: Data?) = try await runRaw()

            Self.storeCookie(from: response.response)

            // If no data expected just return
            if let urlResponse = response.response,
                let rawResponse = RawResponse(httpUrlResponse: urlResponse, data: response.data) as? Response {
                return rawResponse
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

    private func runRaw() async throws -> (HTTPURLResponse?, Data) {

        let urlReq = try build()

        let response: (Data, HTTPURLResponse?) = try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: urlReq) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (data ?? Data(), response as? HTTPURLResponse))
                }
            }.resume()
        }
        let sessionData = response.0
        let sessionResponse = response.1

        if let networkError = NetworkingError(error: nil, response: sessionResponse, data: sessionData) {
            throw networkError
        }
        return (sessionResponse, sessionData)

    }

    private static func storeCookie(from response: HTTPURLResponse?) {
        guard let url = response?.url,
            let headerFields = response?.allHeaderFields as? [String : String] else {
                return
        }

        if let cookie = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url).first {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }

    func build() throws ->  URLRequest {

        guard let configuration = self.configuration else {
            throw NetworkingError.badRequest
        }

        guard var url = URL(string: configuration.baseURL)?
            .appendingPathComponent(path)
            .appendingQueryParameters(configuration.defaultQueryParameters)
            else {
                throw NetworkingError.badRequest
        }

        if method.shouldAppendQueryString() {
            url.appendQueryParameters(self.queryParameters)
        }

        var urlRequest = URLRequest(url: url)

        if authentication == nil && requiresAuthentication {
            throw NetworkingError.unauthorized
        }

        // HTTP Method
        urlRequest.addAuthentication(authentication)
        urlRequest.httpMethod = method.rawValue

        // Headers
        configuration.defaultHeaderFields.allFields.appending(headers: headerFields.allFields).forEach {
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

    var queryParameters: [URLQueryItem] {
        guard let parameters = parameters else {
            return []
        }
        
        return Mirror(reflecting: parameters).children.compactMap { label, value in
            guard let label = label else { return nil }
            
            return URLQueryItem(name: label, value: String(anyValue: value))
        }
    }
}
