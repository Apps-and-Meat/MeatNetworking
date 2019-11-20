//
//  UserNetworkCredentials.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public protocol UserNetworkCredentials {
    func toQueryParameters() -> [String: String]
}
