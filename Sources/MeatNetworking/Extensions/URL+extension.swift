//
//  URL+extension.swift
//  MeetNetworking
//
//  Created by Karl Söderberg on 2019-05-12.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else { return nil }

        var items: [String: String] = [:]

        for queryItem in queryItems {
            items[queryItem.name] = queryItem.value
        }
        return items
    }
}

public extension URL {
    func appendingQueryParameters(_ parameters: Parameters?) -> URL {
        let items = parameters?.map { URLQueryItem(name: $0, value: String(anyValue: $1)) }
        return appendingQueryParameters(items)
    }

    func appendingQueryParameters(_ parameters: [URLQueryItem]?) -> URL {
        guard let parameters = parameters else { return self }
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        var items = urlComponents.queryItems ?? []
        items += parameters
        urlComponents.queryItems = items
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return urlComponents.url!
    }

    mutating func appendQueryParameters(_ parameters: Parameters?) {
        self = appendingQueryParameters(parameters)
    }

    mutating func appendQueryParameters(_ parameters: [URLQueryItem]?) {
        self = appendingQueryParameters(parameters)
    }

    func queryValue(for key: String) -> String? {
        let stringURL = self.absoluteString
        guard let items = URLComponents(string: stringURL)?.queryItems else { return nil }
        for item in items where item.name == key {
            return item.value
        }
        return nil
    }
}
