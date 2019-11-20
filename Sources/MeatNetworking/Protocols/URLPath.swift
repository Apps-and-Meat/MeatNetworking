//
//  URLPath.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public protocol URLPath {
    var requiresAuthentication: Bool { get }
    var toString: String { get }
}

struct EmptyURLPath: URLPath {
    var requiresAuthentication: Bool = false
    var toString: String = ""
}
