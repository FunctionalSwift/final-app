// Copyright © FunctionalSwift.com 2017. All rights reserved.

public typealias Validator<A, E> = (A) -> Future<Result<A, E>>

public func validate<A, E>(_ reason: E, _ condition: @escaping (A) -> Bool) -> Validator<A, E> {
    return { Future.async((condition($0) ? .Success($0) : .Failure(reason))) }
}

public func && <A, E>(
    _ firstValidator: @escaping Validator<A, E>,
    _ secondValidator: @escaping Validator<A, E>) -> Validator<A, E> {

    return {
        firstValidator($0).flatMap { result in
            switch result {
            case let .Success(a):
                return secondValidator(a)
            case let .Failure(reason):
                return Future.pure(.Failure(reason))
            }
        }
    }
}

public func || <A, E>(
    _ firstValidator: @escaping Validator<A, E>,
    _ secondValidator: @escaping Validator<A, E>) -> Validator<A, E> {

    return { a in
        firstValidator(a).flatMap { result in
            switch result {
            case .Success:
                return Future.pure(result)
            case .Failure:
                return secondValidator(a)
            }
        }
    }
}
