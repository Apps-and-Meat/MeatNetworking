//
//  FutureVoid.swift
//  MeetNetworking
//
//  Created by Karl Söderberg on 2019-05-12.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public class FutureVoid {
    let request: () throws -> Void
    var onSuccess: [() -> Void] = []
    var onError: [(Error) -> Void] = []
    var errorMapper: (Error) -> Error = { return $0 }

    public init(result: @escaping () throws -> Void) {
        self.request = result
    }

    public static func failingFuture(_ error: Error) -> FutureVoid {
        return FutureVoid(result: { throw error })
    }

    @discardableResult public func onSuccess(_ block: @escaping () -> Void) -> FutureVoid {
        self.onSuccess.append(block)
        return self
    }
    @discardableResult public func onError(_ block: @escaping (Error) -> Void) -> FutureVoid {
        self.onError.append(block)
        return self
    }

    @discardableResult public func mapError(transform: @escaping (Error) -> Error) -> FutureVoid {
        self.errorMapper = transform
        return self
    }

    public func run() {
        self.run { _ in }
    }

    public func run(_ block: @escaping (GetVoid) -> Void) {
        DispatchQueue.global().async {
            do {
                try self.request()
                DispatchQueue.main.async {
                    self.onSuccess.forEach { $0() }
                    block({})
                }
            } catch {
                let error = self.errorMapper(FutureError.map(error: error))
                DispatchQueue.main.async {
                    self.onError.forEach { $0(error) }
                    block( { throw error })
                }
            }
        }
    }

    public func runSynchronous() throws {
        do {
            try self.request()
            DispatchQueue.main.async {
                self.onSuccess.forEach { $0() }
            }
        } catch {
            let error = FutureError.map(error: error)
            DispatchQueue.main.async {
                self.onError.forEach { $0(error) }
            }
            throw error
        }
    }
}
