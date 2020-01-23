//
//  FutureError.swift
//  MeetNetworking
//
//  Created by Karl Söderberg on 2019-05-12.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public enum FutureError: Error, Equatable {
    case unauthorized
    case badRequest
    case dataDecodingError
    case noData
    case warning(String, Data?)
    case cancelled

    public func getWarning() -> (String, Data?)? {
        switch self {
        case let .warning(warning, data):
            return (warning, data)
        default: return nil
        }
    }

    public static func isCancelled(_ error: Error?) -> Bool {
        guard
            let error = error,
            let futureError = FutureError.map(error: error) as? FutureError
            else {
                return false
        }

        switch futureError {
        case .cancelled: return true
        default: return false
        }
    }

    static func map(error: Error) -> Error {
        if error is UnauthorizedError {
            return self.unauthorized
        }
        return error
    }

    public static func ==(lhs: Error, rhs: FutureError) -> Bool {
        guard let lhs = FutureError.map(error: lhs) as? FutureError else { return false }
        return lhs == rhs
    }

    public static func ==(lhs: FutureError, rhs: FutureError) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorized, .unauthorized): return true
        case (.cancelled, .cancelled): return true
        case (.noData, .noData): return true
        case (.dataDecodingError, .dataDecodingError): return true
        case let (.warning(lhsW, lhsD), .warning(rhsW, rhsD)):
            return lhsW == rhsW && lhsD == rhsD
        default:
            return false
        }
    }
}
