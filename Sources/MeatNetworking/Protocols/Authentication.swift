//
//  Authentication.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public enum Authentication {
    case none
    case OAuth2(String)
    case custom(HTTPHeaderFields)
}
