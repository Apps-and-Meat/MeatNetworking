//
//  RequestBuilder.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public protocol RequestableBuilder: Requestable {
    func method(_ method: HTTPMethod) -> RequestableBuilder
    func path(_ path: URLPath) -> RequestableBuilder
    func parameters(_ parameters: Parameters) -> RequestableBuilder
    func parameters<T: Encodable>(_ parameters: T) -> RequestableBuilder
    func authentication(_ authentication: Authentication) -> RequestableBuilder
    func headers(_ headers: HTTPHeaderFields) -> RequestableBuilder
    func appendHeader(key: String, value: String?) -> RequestableBuilder
    func disableAuthorizationLogout() -> RequestableBuilder
}

open class RequestBuilder: RequestableBuilder {
    
    public let configuration: NetworkingConfiguration
    public let createDate = Date().hashValue
    public var currentRequest: URLSessionDataTask?
    public var isRunning = false {
        didSet {
            if oldValue == true && isRunning == false {
                onFinished?(self)
            }
        }
    }
    public var isCancelled: Bool {
        return currentRequest?.progress.isCancelled ?? false
    }

    public var method: HTTPMethod = .get
    public var path: URLPath = EmptyURLPath()
    public var parameters: Parameters? = nil
    public var authentication: Authentication
    public var headerFields: HeaderFieldList
    public var logOutIfUnauthorized: Bool = true
    
    private var onFinished: ((RequestBuilder) -> Void)?

    init(configuration: NetworkingConfiguration,
         authentication: Authentication,
         onFinished: @escaping (RequestBuilder) -> Void) {
        self.configuration = configuration
        self.authentication = authentication
        self.onFinished = onFinished
        self.headerFields = configuration.defaultHeaderFields
    }

    public func headers(_ headers: HTTPHeaderFields) -> RequestableBuilder {
        headerFields.custom.merge(headers) { old, new in
            return new
        }
        return self
    }

    public func appendHeader(key: String, value: String?) -> RequestableBuilder {
        self.headerFields.custom[key] = value
        return self
    }

    public func method(_ method: HTTPMethod) -> RequestableBuilder {
        self.method = method
        return self
    }

    public func path(_ path: URLPath) -> RequestableBuilder {
        self.path = path
        return self
    }

    public func parameters(_ parameters: Parameters) -> RequestableBuilder {
        self.parameters = parameters
        return self
    }

    public func authentication(_ authentication: Authentication) -> RequestableBuilder {
        self.authentication = authentication
        return self
    }

    public func parameters<T: Encodable>(_ parameters: T) -> RequestableBuilder {
        do {
            let json: Parameters = try configuration.encoder.encodeToParams(parameters)
            return self.parameters(json)
        } catch {
            print(error)
            return self
        }
    }

    public func disableAuthorizationLogout() -> RequestableBuilder {
        logOutIfUnauthorized = false
        return self
    }

    public func setIsRunning(_ running: Bool) {
        self.isRunning = running
    }

    public func cancelRequests() {
        self.currentRequest?.cancel()
        self.isRunning = false
    }
}
