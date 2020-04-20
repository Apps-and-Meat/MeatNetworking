//
//  HTTPMethod.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public enum HTTPMethod : String {

    case options

    case get

    case head

    case post

    case put

    case patch

    case delete

    case trace

    case connect

    func shouldAddHTTPBody() -> Bool {
        return self == .put || self == .post || self == .patch
    }

    func shouldAppendQueryString() -> Bool {
        return self == .get
    }
}
