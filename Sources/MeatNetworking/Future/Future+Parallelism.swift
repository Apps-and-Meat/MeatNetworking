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
        return Self.paralleling(futureA: self, futureB: future)
    }
    
    private static func paralleling<A, B>(futureA: Future<A>, futureB: Future<B>) -> Future<(A, B)> {

        return Future<(A,B)> {
            var a: GetResult<A> = { throw FutureError.cancelled}
            var b: GetResult<B> = { throw FutureError.cancelled}

            let group = DispatchGroup()
            group.enter()
            futureA.run { getA in
                do {
                    let aResult = try getA()
                    a = { return aResult }
                } catch {
                    a = { throw error }
                }
                group.leave()
            }
            group.enter()
            futureB.run { getB in
                do {
                    let bResult = try getB()
                    b = { return bResult }
                } catch {
                    b = { throw error }
                }
                group.leave()
            }
            group.wait()
            return (try a(), try b())
        }
    }
}
