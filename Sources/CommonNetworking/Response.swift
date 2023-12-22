//  ______   ______    ______   __     __
// /\  ___\ /\  __ \  /\__  _\ /\ \  _ \ \
// \ \  __\ \ \ \/\ \ \/_/\ \/ \ \ \/ ".\ \
//  \ \_\    \ \_____\   \ \_\  \ \__/".~\_\
//   \/_/     \/_____/    \/_/   \/_/   \/_/
//
//  Created by Marco Brugnera on 26/10/22.
//

import Foundation

/// Enum for all the errors handled by the library
public enum NetworkError<E: Decodable>: Error {
    /// Error thrown when the status code is not recognized. Will try to map the return body with the generic error model (E).
    /// - parameters
    ///     - body: return type mapped to the generic error model (if possible).
    ///     - statusCode: status code returned by the API.
    case genericError(body: E?, statusCode: Int, parseResult: ParseResult)
    /// Error thrown when the status code is between 400 and 499. Will try to map the return body with the generic error model (E).
    /// - parameters
    ///     - body: return type mapped to the generic error model (if possible).
    ///     - statusCode: status code returned by the API.
    case clientError(body: E?, statusCode: Int, parseResult: ParseResult)
    /// Error thrown when the status code is between 500 and 599. Will try to map the return body with the generic error model (E).
    /// - parameters
    ///     - body: return type mapped to the generic error model (if possible).
    ///     - statusCode: status code returned by the API.
    case serverError(body: E?, statusCode: Int, parseResult: ParseResult)
    /// Error thrown when the response data can not be mapped to the defined type T. Will try to map the return body with the generic error model (E).
    /// - parameters
    ///     - error: the error that causes the failure.
    ///     - statusCode: status code returned by the API.
    case decodeError(_ error: Error, statusCode: Int)
    /// Error thrown when the server response is empty.
    /// - parameters
    ///     - message: a message describing the cause of the error.
    ///     - statusCode: status code returned by the API.
    case emptyBodyError(message: String, statusCode: Int)
    /// Error thrown when the server response is null.
    /// - parameters
    ///     - statusCode: status code returned by the API.
    case invalidResponseBodyError(statusCode: Int)
}

public enum ParseResult: Equatable {
    case success
    /// Parse result when the response data can not be mapped to the defined type T. Will try to map the return body with the generic error model (E).
    /// - parameters
    ///     - message: the error that causes the failure.
    case decodeError(message: String)
    /// Parse result when the server response is empty.
    /// - parameters
    ///     - message: a message describing the cause of the error.
    case emptyBodyError(message: String)
    /// Parse result thrown when the server response is null.
    case invalidResponseBodyError
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .genericError(let body, let statusCode, _):
            return "Generic Error: \(statusCode) \(String(describing: body))"
        case .clientError(let body, let statusCode, _):
            return "Client Error: \(statusCode) \(String(describing: body))"
        case .serverError(let body, let statusCode, _):
            return "Server Error: \(statusCode) \(String(describing: body))"
        case .decodeError(let error, let statusCode):
            return "Decode Error: \(NetworkError.parseDecodingError(error: error)), with statusCode \(statusCode)"
        case .emptyBodyError(let message, let statusCode):
            return "Empty body Error: \(message), with statusCode \(statusCode)"
        case .invalidResponseBodyError(let statusCode):
            return "Invalid response body Error: \(statusCode)"
        }
    }

    static internal func parseDecodingError(error: Error) -> String {
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .typeMismatch(_, let context):
                var description = context.debugDescription
                if let element = context.codingPath.first {
                    description += " For key: \(element.stringValue)"
                }
                return description
            case .valueNotFound(_, let context):
                var description = context.debugDescription
                if let element = context.codingPath.first {
                    description += " For key: \(element.stringValue)"
                }
                return description
            case .keyNotFound(let codingKey, _):
                return "Missing field: \(codingKey.stringValue)"
            case .dataCorrupted(let context):
                var description = context.debugDescription
                if let element = context.codingPath.first {
                    description += " For key: \(element.stringValue)"
                }
                return description
            default:
                return error.localizedDescription
            }
        }
        return error.localizedDescription
    }
}

/// Object to handle empty body response from APIs
public struct EmptyContent: Decodable, Equatable {}
