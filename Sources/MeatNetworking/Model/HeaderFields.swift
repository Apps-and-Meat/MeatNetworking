//
//  File.swift
//  
//
//  Created by Karl Söderberg on 2019-11-26.
//

import Foundation

public struct HeaderFields {
    
    var contentType: DataType = .json
    var accept: DataType = .json
    
    var custom = HTTPHeaderType()
    
    var allValues: HTTPHeaderType {
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

enum HeaderFieldKey: CustomStringConvertible {
    case contentType
    case accept
    case other(String)
    
    var description: String {
        switch self {
        case .contentType:
            return "Content-Type"
        case .accept:
            return "Accept"
        case .other(let string):
            return string
        }
    }
}

enum DataType: String, Codable {
    case json = "application/json"
    case form = "application/x-www-form-urlencoded"
}
