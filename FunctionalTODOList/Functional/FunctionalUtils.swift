// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

infix operator |>: AdditionPrecedence

public func |> <T, U, V>(first: @escaping (T) -> U, second: @escaping (U) -> V) -> ((T) -> V) {
    return { second(first($0)) }
}

infix operator <*>: AdditionPrecedence
infix operator <%>: AdditionPrecedence

// MAP
public func <%> <A, B, E>(_ transform: @escaping (A) -> B, futureResultA: Future<Result<A, E>>) -> Future<Result<B, E>> {

    return futureResultA.map { result in
        result.map(transform)
    }
}

// APPLY
public func <*> <A, B, E>(_ futureResultAB: Future < Result < (A) -> B, E>>, futureResultA: Future<Result<A, E>>) -> Future<Result<B, E>> {
    return futureResultA.map2(futureResultAB) { resultA, resultAB in
        resultA.apply(resultAB)
    }
}

// FLATMAP
public func >>= <A, B, E>(_ futureResultA: Future<Result<A, E>>, transform: @escaping (A) -> Future<Result<B, E>>) -> Future<Result<B, E>> {

    return futureResultA.flatMap { result in
        switch result {
        case let .Success(a):
            return transform(a)
        case let .Failure(reason):
            return Future.pure(.Failure(reason))
        }
    }
}
