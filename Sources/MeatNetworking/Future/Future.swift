//
//  Future.swift
//  MeetNetworking
//
//  Created by Karl Söderberg on 2019-05-12.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public typealias GetResult<T> = () throws -> (T)
public typealias GetVoid = () throws -> ()

public class Future<T> {
    let request: () throws -> T
    var onSuccess: [(T) -> Void] = []
    var onError: [(Error) -> Void] = []
    var errorMapper: (Error) -> Error = { return $0 }

    public init(result: @escaping () throws -> T) {
        self.request = result
    }

    public static func failingFuture<T>(_ error: Error) -> Future<T> {
        return Future<T>(result: { throw error })
    }

    @discardableResult public func onSuccess(_ block: @escaping (T) -> Void) -> Future<T> {
        self.onSuccess.append(block)
        return self
    }
    @discardableResult public func onError(_ block: @escaping (Error) -> Void) -> Future<T> {
        self.onError.append(block)
        return self
    }

    public func run() {
        self.run { _ in }
    }

    public func run(_ block: @escaping (GetResult<T>) -> Void) {
        DispatchQueue.global().async {
            do {
                let result = try self.request()
                DispatchQueue.main.async {
                    self.onSuccess.forEach { $0(result) }
                    block({ return result })
                }
            } catch {
                let error = self.errorMapper(FutureError.map(error: error))
                DispatchQueue.main.async {
                    self.onError.forEach { $0(error) }
                    block({ throw error })
                }
            }
        }
    }

    public func runSynchronous() throws -> T {
        do {
            let result = try self.request()
            DispatchQueue.main.async {
                self.onSuccess.forEach { $0(result) }
            }
            return result
        } catch {
            let error = self.errorMapper(FutureError.map(error: error))
            DispatchQueue.main.async {
                self.onError.forEach { $0(error) }
            }
            throw error
        }
    }

    public func mapToVoid() -> Future<Void> {
        return Future<Void> {
            do {
                let result = try self.request()
                DispatchQueue.main.async {
                    self.onSuccess.forEach { $0(result) }
                }
            } catch {
                let error = self.errorMapper(FutureError.map(error: error))
                DispatchQueue.main.async {
                    self.onError.forEach { $0(error) }
                }
                throw error
            }
        }
    }

    public func map<E>(transform: @escaping (T) throws -> E) -> Future<E> {
        return Future<E> {
            do {
                let result = try self.request()
                DispatchQueue.main.async {
                    self.onSuccess.forEach { $0(result) }
                }
                return try transform(result)
            } catch {
                let error = self.errorMapper(FutureError.map(error: error))
                DispatchQueue.main.async {
                    self.onError.forEach { $0(error) }
                }
                throw error
            }
        }
    }

    @discardableResult public func mapError(transform: @escaping (Error) -> Error) -> Future<T> {
        self.errorMapper = transform
        return self
    }
}
