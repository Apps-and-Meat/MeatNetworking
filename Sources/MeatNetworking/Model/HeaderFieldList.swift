//
//  File.swift
//  
//
//  Created by Karl Söderberg on 2019-11-26.
//

import Foundation

public struct HeaderFieldList {
    
    public var contentType: DataType = .json
    public var accept: DataType = .json

    public var custom = HTTPHeaderFields()

    public var allFields: HTTPHeaderFields {
        var values: HTTPHeaderFields = [
            "Content-Type": contentType.rawValue,
            "Accept": accept.rawValue
        ]
        values.merge(custom) { old, new in
            return new
        }
        return values
    }


}

extension HTTPHeaderFields {
    public func appending(headers: HTTPHeaderFields) -> HTTPHeaderFields {
        merging(headers) { old, new in
            return new
        }
    }
}

public enum DataType: String, Codable {
    case json = "application/json"
    case form = "application/x-www-form-urlencoded"
}
