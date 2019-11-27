//
//  File.swift
//  
//
//  Created by Karl Söderberg on 2019-11-26.
//

import Foundation

public struct HeaderFields {
    
    public var contentType: DataType = .json
    public var accept: DataType = .json

    public var custom = HTTPHeaderType()

    public var allValues: HTTPHeaderType {
        var values: HTTPHeaderType = [
            "Content-Type": contentType.rawValue,
            "Accept": accept.rawValue
        ]
        values.merge(custom) { old, new in
            return new
        }
        return values
    }
}

public enum DataType: String, Codable {
    case json = "application/json"
    case form = "application/x-www-form-urlencoded"
}
