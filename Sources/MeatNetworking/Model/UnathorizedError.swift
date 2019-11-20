//
//  UnathorizedError.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public enum UnauthorizedError: Int, Error {
    case unauthorized = 401

    public init() {
        self = .unauthorized
    }

    init?(code: Int?) {
        guard let code = code else { return nil }
        self.init(rawValue: code)
    }
}
