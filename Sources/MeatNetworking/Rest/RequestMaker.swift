//
//  RequestMaker.swift
//  MeatNetworking
//
//  Created by Karl Söderberg on 2019-10-16.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public class RequestMaker {
        
    static func performRequest<T: Decodable>(request: Requestable, expecting: T.Type, retryCount: Int = 0) async throws -> T {
        do {
            
            let response: (response: HTTPURLResponse?, data: Data?) = try await self.performRequest(request: request)
            
            storeCookie(from: response.response)
            
            // If no data expected just return
            if let void = VoidResult() as? T {
                return void
            }
            
            // Check if we have any sessionData else throw nodata error
            guard let validatedSessionData = response.data else {
                throw NetworkingError.notFound
            }
            
            // If raw Data expected just return sessionData
            if let data = validatedSessionData as? T {
                return data
            }
            
            do {
                return try request.configuration.decoder.decode(T.self, from: validatedSessionData)
            } catch {
                print(error)
                throw NetworkingError(underlyingError: error, data: validatedSessionData, statusCode: response.response?.status)
            }
            
        } catch let error as NetworkingError {
            if request.logOutIfUnauthorized, error.isUnauthorized, let unathorizedHandler = request.configuration.defaultUnathorizedAccessHandler {
                    
                do {
                    let successfulRecover = (try? await unathorizedHandler.recover(retryCount: retryCount)) ?? false
                    
                    if successfulRecover {
                        return try await self.performRequest(request: request, expecting: expecting, retryCount: retryCount + 1)
                    } else {
                        unathorizedHandler.afterFailedRecover()
                    }
                }
            }
            
            throw request.configuration.errorMapping(error)
        }
    }
    
    public static func performRequest(request: Requestable) async throws -> (HTTPURLResponse?, Data?) {
        var sessionData: Data?
        var sessionError: Error?
        var sessionResponse: HTTPURLResponse?
        let group = DispatchGroup()
        let urlReq = try request.build()
        
        group.enter()
        let task = URLSession.shared.dataTask(with: urlReq) { data, response, error in
            sessionData = data
            sessionError = error
            sessionResponse = response as? HTTPURLResponse
            group.leave()
        }
        
        task.resume()
        request.setIsRunning(true)
        group.wait()
        request.setIsRunning(false)
        
        if let networkError = NetworkingError(error: sessionError, response: sessionResponse, data: sessionData) {
            throw networkError
        }
        
        return (sessionResponse, sessionData)
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
