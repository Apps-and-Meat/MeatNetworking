//
//  CoreEncoder.swift
//  MeetNetworking
//
//  Created by Karl Söderberg on 2019-05-12.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public class CoreEncoder: JSONEncoder {

    public override init() {
        super.init()
        self.dateEncodingStrategy = .formatted(.networkFormatter)
        self.keyEncodingStrategy = .useDefaultKeys
    }
}

public extension JSONEncoder {
    func encodeToParams<T>(_ value: T) throws -> Parameters where T : Encodable {
        do {
            let jsonData = try encode(value)
            if let params = try JSONSerialization.jsonObject(with: jsonData) as? Parameters {
                return params
            }
        } catch {
            throw error
        }
        throw NetworkingError.badRequest
    }
}

private struct CoreEncoderKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}
