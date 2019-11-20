//
//  FutureHelper.swift
//  MeetNetworking
//
//  Created by Karl Söderberg on 2019-05-12.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public struct FutureHelper {
    public static func paralleling<A, B>(futureA: Future<A>, futureB: Future<B>) -> Future<(A, B)> {

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

    public static func paralleling<A>(futureA: Future<A>, futureB: FutureVoid) -> Future<A> {

        return Future<A> {
            var a: GetResult<A> = { throw FutureError.cancelled}
            var b: GetVoid = { throw FutureError.cancelled}

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
                    try getB()
                    b = { }
                } catch {
                    b = { throw error }
                }
                group.leave()
            }
            group.wait()

            try b()
            return try a()
        }
    }

    public static func paralleling(futureA: FutureVoid, futureB: FutureVoid) -> FutureVoid {

        return FutureVoid {
            var a: GetVoid = { throw FutureError.cancelled}
            var b: GetVoid = { throw FutureError.cancelled}

            let group = DispatchGroup()
            group.enter()
            futureA.run { getA in
                do {
                    try getA()
                    a = { }
                } catch {
                    a = { throw error }
                }
                group.leave()
            }
            group.enter()
            futureB.run { getB in
                do {
                    try getB()
                    b = { return }
                } catch {
                    b = { throw error }
                }
                group.leave()
            }
            group.wait()

            try b()
            try a()
        }
    }
}
