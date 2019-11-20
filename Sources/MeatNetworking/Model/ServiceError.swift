////
////  ServiceError.swift
////  Networking
////
////  Created by Karl Söderberg on 2019-05-10.
////  Copyright © 2019 Cabonline Technologies AB. All rights reserved.
////
//
//import Foundation
//
//public enum ServiceError: Error {
//    case dataDecodingError
//    case noData
//    case warning(String, Data?)
//    case cancelled
//
//    public static func isCancelled(_ error: Error?) -> Bool {
//        switch error as? ServiceError {
//        case .some(.cancelled): return true
//        default: return false
//        }
//    }
//}
