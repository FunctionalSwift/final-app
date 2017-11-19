// Copyright © FunctionalSwift.com 2017. All rights reserved.

import Foundation

typealias FTask<A> = (DispatchQueue, DispatchGroup, @escaping (A) -> Void) -> Void

public struct Future<A> {
    let task: FTask<A>

    public static func async(_ getValue: @autoclosure @escaping () -> A) -> Future<A> {
        let task: FTask<A> = { queue, group, continuation in
            queue.async(group: group) {
                continuation(getValue())
            }
        }

        return Future(task: task)
    }

    public static func sync(_ getValue: @autoclosure @escaping () -> A) -> Future<A> {
        let task: FTask<A> = { _, _, continuation in
            continuation(getValue())
        }

        return Future(task: task)
    }

    public func runAsync(_ queue: DispatchQueue = DispatchQueue.global(), _ continuation: @escaping (A) -> Void) {
        task(queue, DispatchGroup(), continuation)
    }

    public func runSync() -> A {
        let queue = DispatchQueue.global()
        let group = DispatchGroup()

        var a: A?

        task(queue, group) { value in
            a = value
        }

        group.wait()

        return a!
    }

    // FUNCTOR

    public func map<B>(_ transform: @escaping (A) -> B) -> Future<B> {
        return flatMap { a in
            let task: FTask<B> = { _, _, continuation in
                continuation(transform(a))
            }

            return Future<B>(task: task)
        }
    }

    // MONADA: FUNCTOR + MONOIDE

    public func flatMap<B>(_ transform: @escaping (A) -> Future<B>) -> Future<B> {
        let task: FTask<B> = { queue, group, continuation in
            self.task(queue, group) { a in
                let futureB = transform(a)

                futureB.task(queue, group, continuation)
            }
        }

        return Future<B>(task: task)
    }

    // APLICATIVO

    public static func pure(_ value: A) -> Future<A> {
        let task: FTask = { _, _, continuation in
            continuation(value)
        }

        return Future(task: task)
    }

    // Funcion map que opera con dos elementos
    public func map2<B, C>(_ futureB: Future<B>, _ transform: @escaping (A, B) -> C) -> Future<C> {

        let task: FTask<C> = { queue, _, continuation in

            let group = DispatchGroup()

            var a: A?
            var b: B?

            self.task(queue, group) { value in
                a = value
            }

            futureB.task(queue, group) { value in
                b = value
            }

            group.wait()

            continuation(transform(a!, b!))
        }

        return Future<C>(task: task)
    }

    public func apply<B>(_ futureAB: Future < (A) -> B>) -> Future<B> {
        return map2(futureAB) { a, transform in
            transform(a)
        }
    }
}
