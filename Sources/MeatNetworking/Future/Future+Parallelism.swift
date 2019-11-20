//
//  Future+Parallelism.swift
//  MeetNetworking
//
//  Created by Karl Söderberg on 2019-05-12.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public extension Future {
    func parallel<E>(with future: Future<E>) -> Future<(T, E)> {
        return FutureHelper.paralleling(futureA: self, futureB: future)
    }
    func parallel(with future: FutureVoid) -> Future<T> {
        return FutureHelper.paralleling(futureA: self, futureB: future)
    }
}

public extension FutureVoid {
    func parallel<E>(with future: Future<E>) -> Future<E> {
        return FutureHelper.paralleling(futureA: future, futureB: self)
    }
    func parallel(with future: FutureVoid) -> FutureVoid {
        return FutureHelper.paralleling(futureA: self, futureB: future)
    }
}
