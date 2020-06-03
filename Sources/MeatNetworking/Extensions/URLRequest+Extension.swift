//
//  URLRequest+Extension.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2020-06-03.
//

import Foundation

extension URLRequest {
    mutating func addAuthentication(_ auth: Authentication) {
        switch auth {
        case .custom(let headerFields):
            headerFields.forEach {
                setValue($0.value, forHTTPHeaderField: $0.key)
            }
        case .OAuth2(let token):
            setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        case .none:
            break
        }
    }
}
