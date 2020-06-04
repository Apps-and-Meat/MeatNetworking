//
//  RequestMaker.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation
import Combine

public class RequestMaker {
    
    static func performRequest<T: Decodable>(request: Requestable, expecting: T.Type) -> Future<T, NetworkingError> {
//        do {
            self.performRequest(request: request).tryMap { (response, data) -> T in
                self.storeCookie(from: response)
                
                // If no data expected just return
                if let void = VoidResult() as? T {
                    return void
                }
                
                // Check if we have any sessionData else throw nodata error
                guard let validatedSessionData = data else {
                    throw NetworkingError.notFound
                }
                
                // If raw Data expected just return sessionData
                if let data = validatedSessionData as? T {
                    return data
                }
                
                do {
                    return try request.configuration.decoder.decode(T.self, from: validatedSessionData)
                } catch {
                    throw NetworkingError(underlyingError: error, data: validatedSessionData, statusCode: response?.status)
                }
            }.mapError { error in
                let networkError = error as? NetworkingError ?? NetworkingError(underlyingError: error, data: nil, statusCode: HTTPStatusCode(rawValue: error._code))
                if request.logOutIfUnauthorized, networkError.isUnauthorized {
                    request.configuration.defaultUnathorizedAccessHandler?()
                }
                return networkError
//                            throw request.configuration.errorMapping(error)
                }
            .eraseToAnyPublisher()
//            }
//
//            storeCookie(from: response.response)
//
//            // If no data expected just return
//            if let void = VoidResult() as? T {
//                return void
//            }
//
//            // Check if we have any sessionData else throw nodata error
//            guard let validatedSessionData = response.data else {
//                throw NetworkingError.notFound
//            }
//
//            // If raw Data expected just return sessionData
//            if let data = validatedSessionData as? T {
//                return data
//            }
//
//            do {
//                return try request.configuration.decoder.decode(T.self, from: validatedSessionData)
//            } catch {
//                print(error)
//                throw NetworkingError(underlyingError: error, data: validatedSessionData, statusCode: response.response?.status)
//            }
            
//        } catch let error as NetworkingError {
//            if request.logOutIfUnauthorized, error.isUnauthorized {
//                request.configuration.defaultUnathorizedAccessHandler?()
//            }
//            throw request.configuration.errorMapping(error)
//        }
    }
        
    public static func performRequest(request: Requestable) -> Future<(HTTPURLResponse?, Data?), NetworkingError> {
//        var sessionData: Data?
//        var sessionError: Error?
//        var sessionResponse: HTTPURLResponse?
//        let group = DispatchGroup()
        let urlReq: URLRequest
            
        do {
           urlReq = try request.build()
        } catch {
            return Future<(HTTPURLResponse?, Data?), NetworkingError> { promise in
                promise(.failure(NetworkingError(underlyingError: error, data: nil, statusCode: .badRequest)))
            }
//            return Fail(error: NetworkiwngError(underlyingError: error, data: nil, statusCode: .badRequest))
        }
        
//        group.enter()
        
        return URLSession.shared.dataTaskPublisher(for: urlReq)
            
            .tryMap { (data: Data, response: URLResponse) -> (HTTPURLResponse?, Data?) in
                
            let urlResponse = response as? HTTPURLResponse
            if let networkError = NetworkingError(error: nil, response: urlResponse, data: data) {
                throw networkError
            }
            
            return (urlResponse, data)
        }.mapError { error in
            error as? NetworkingError ?? NetworkingError(underlyingError: error, data: nil, statusCode: HTTPStatusCode(rawValue: error._code))
        }.eraseToAnyPublisher()
        
//        let task = URLSession.shared.dataTask(with: urlReq) { data, response, error in
//            sessionData = data
//            sessionError = error
//            sessionResponse = response as? HTTPURLResponse
//            group.leave()
//        }
//
//        task.resume()
//        request.setIsRunning(true)
//        group.wait()
//        request.setIsRunning(false)
//
//        if let networkError = NetworkingError(error: sessionError, response: sessionResponse, data: sessionData) {
//            throw networkError
//        }
//
//        return (sessionResponse, sessionData)
    }
    
    private static func storeCookie(from response: HTTPURLResponse?) {
        guard   let url = response?.url,
            let headerFields = response?.allHeaderFields as? [String : String] else {
                return
        }
        
        if let cookie = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url).first {
            print("Storing cookie for \(url.path)")
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }
}

