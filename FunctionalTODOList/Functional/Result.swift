// Copyright © FunctionalSwift.com 2017. All rights reserved.

public enum Result<A, E> {
    case Success(_: A)
    case Failure(_: E)

    public static func pure(_ a: A) -> Result<A, E> {
        return .Success(a)
    }

    public func map<B>(_ transform: (A) -> B) -> Result<B, E> {
        return flapMap {
            .Success(transform($0))
        }
    }

    public func flapMap<B>(_ transform: (A) -> Result<B, E>) -> Result<B, E> {
        switch self {
        case let .Failure(reason):
            return .Failure(reason)
        case let .Success(value):
            return transform(value)
        }
    }

    public func apply<B>(_ resultAB: Result < (A) -> B, E>) -> Result<B, E> {
        return flapMap { a in
            resultAB.map { transform in
                transform(a)
            }
        }
    }

    func isFailure() -> Bool {

        switch self {
        case .Failure:
            return true
        case .Success:
            return false
        }
    }

    func isSuccess() -> Bool {
        return !isFailure()
    }

    func mapFailure<U>(_ transformFailure: (E) -> U) -> Result<A, U> {

        switch self {
        case let .Failure(reason):
            return .Failure(transformFailure(reason))
        case let .Success(value):
            return .Success(value)
        }
    }

    func ifSuccess(_ completion: (A) -> Void) {
        fold(completion, { _ in })
    }

    func ifFailure(_ completion: (E) -> Void) {
        fold({ _ in }, completion)
    }

    func fold(_ onSuccess: (A) -> Void, _ onFailure: (E) -> Void) {
        switch self {
        case let .Failure(reason):
            onFailure(reason)
        case let .Success(value):
            onSuccess(value)
        }
    }
}
