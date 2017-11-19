// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit
import Alamofire

enum WSError: Error {
    case DataRequired(Message: String)
    case NoData(Message: String)
    case GenericError(Message: String)

    func description() -> String {
        switch self {
        case let .DataRequired(message):
            return message

        case let .NoData(message):
            return message

        case let .GenericError(message):
            return message
        }
    }
}

typealias APIBasicSuccessCompletionBlock = (_ json: Any?) -> Void
typealias APIBasicErrorCompletionBlock = (_ error: Error) -> Void

class NetworkHandler: NSObject {

    let baseURL = "http://localhost:3000/"
    let headers = ["Content-Type": "application/json"]

    static let urlCache: URLCache = {

        let capacity = 50 * 1024 * 1024
        let urlCache = URLCache(memoryCapacity: capacity, diskCapacity: capacity, diskPath: nil)

        return urlCache
    }()

    static let manager: SessionManager = {

        let configuration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
            configuration.requestCachePolicy = .useProtocolCachePolicy
            configuration.urlCache = urlCache

            return configuration
        }()

        return SessionManager(configuration: configuration)
    }()

    // MARK: Request helpers

    // MARK: GET

    func performBasicGetWithPath(_ path: String, onSuccess: @escaping APIBasicSuccessCompletionBlock, onError: @escaping APIBasicErrorCompletionBlock) {
        performBasicGetWithPath(path, parameters: nil, onSuccess: onSuccess, onError: onError)
    }

    func performBasicGetWithPath(_ path: String, parameters: Dictionary<String, Any>!, onSuccess: @escaping APIBasicSuccessCompletionBlock, onError: @escaping APIBasicErrorCompletionBlock) {

        defaultRequest(path, method: .get, parameters: parameters, onSuccess: onSuccess, onError: onError)
    }

    // MARK: POST

    func performBasicPostWithPath(_ path: String, onSuccess: @escaping APIBasicSuccessCompletionBlock, onError: @escaping APIBasicErrorCompletionBlock) {
        performBasicPostWithPath(path, parameters: nil, onSuccess: onSuccess, onError: onError)
    }

    func performBasicPostWithPath(_ path: String, parameters: Dictionary<String, Any>!, onSuccess: @escaping APIBasicSuccessCompletionBlock, onError: @escaping APIBasicErrorCompletionBlock) {

        defaultRequest(path, method: .post, parameters: parameters, onSuccess: onSuccess, onError: onError)
    }

    // MARK: PUT

    func performBasicPutWithPath(_ path: String, onSuccess: @escaping APIBasicSuccessCompletionBlock, onError: @escaping APIBasicErrorCompletionBlock) {
        performBasicPutWithPath(path, parameters: nil, onSuccess: onSuccess, onError: onError)
    }

    func performBasicPutWithPath(_ path: String, parameters: Dictionary<String, Any>!, onSuccess: @escaping APIBasicSuccessCompletionBlock, onError: @escaping APIBasicErrorCompletionBlock) {

        defaultRequest(path, method: .put, parameters: parameters, onSuccess: onSuccess, onError: onError)
    }

    // MARK: DELETE

    func performBasicDeleteWithPath(_ path: String, onSuccess: @escaping APIBasicSuccessCompletionBlock, onError: @escaping APIBasicErrorCompletionBlock) {
        performBasicDeleteWithPath(path, parameters: nil, onSuccess: onSuccess, onError: onError)
    }

    func performBasicDeleteWithPath(_ path: String, parameters: Dictionary<String, Any>!, onSuccess: @escaping APIBasicSuccessCompletionBlock, onError: @escaping APIBasicErrorCompletionBlock) {

        defaultRequest(path, method: .delete, parameters: parameters, onSuccess: onSuccess, onError: onError)
    }

    // MARK: DEFAULT

    func defaultRequest(_ path: String, method: HTTPMethod, parameters: Dictionary<String, Any>!, onSuccess: @escaping APIBasicSuccessCompletionBlock, onError: @escaping APIBasicErrorCompletionBlock) {

        // Applying Continuation Passing Style
        NetworkHandler.manager.request(baseURL + path, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {

            if $0.result.isSuccess {
                if let json = $0.result.value {

                    if let jsonArray = json as? Array<AnyObject> {
                        onSuccess(jsonArray)
                    } else if let jsonDictionary = json as? Dictionary<String, AnyObject> {
                        onSuccess([jsonDictionary as AnyObject])
                    }
                }
            } else if $0.result.isFailure {
                onError(($0.result.error as Error?)!)
            }
        }
    }
}
