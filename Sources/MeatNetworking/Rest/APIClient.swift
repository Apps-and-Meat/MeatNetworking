//
//  APIClient.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

@available(iOS 15.0.0, *)
open class APIClient {
    public var authentication: Authentication = .none
    public var configuration: NetworkingConfiguration
    private var requests: [RequestBuilder] = []
    
    open var isCancelled: Bool = false
    
    open var isRunning: Bool {
        return !requests.isEmpty
    }
    
    private let requestAccessQueue = DispatchQueue.init(label: "requestAccess")
    
    
    public init(configuration: NetworkingConfiguration) {
        self.configuration = configuration
    }
    
    public func method(_ method: HTTPMethod) -> RequestBuilder {
        isCancelled = false
        let builder = newBuilder()
        builder.method = method
        return builder
    }
    
    open func cancelRequests() {
        requestAccessQueue.async {
            self.requests.forEach { $0.cancelRequests() }
            self.requests.removeAll()
        }
        
        isCancelled = true
    }
    
    private func newBuilder() -> RequestBuilder {
        let newBuilder = RequestBuilder(configuration: configuration,
                                        authentication: authentication,
                                        onFinished: self.didFinishRequest)
        requestAccessQueue.async {
            self.requests.append(newBuilder)
        }
        return newBuilder
    }
    
    private func didFinishRequest(_ request: RequestBuilder ) {
        requestAccessQueue.async {
            self.requests.removeAll { $0.createDate == request.createDate }
        }
    }
}
