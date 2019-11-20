//
//  CoreDecoder.swift
//  MeetNetworking
//
//  Created by Karl Söderberg on 2019-05-12.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public class CoreDecoder: JSONDecoder {
    override public init() {
        super.init()
        self.dateDecodingStrategy = .formatted(.networkFormatter)
        self.keyDecodingStrategy = .custom { keys -> CodingKey in
            let key = keys.last!.stringValue.lowerCaseFirstLetter()
            return CoreDecoderKey(stringValue: key)!
        }
    }

    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        if let noData = VoidResult() as? T {
            return noData
        }

        return try super.decode(type, from: data)
    }
}

private struct CoreDecoderKey: CodingKey {
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


extension DateFormatter {
    static let networkFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()

    public static let regionDataMessageFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
}
