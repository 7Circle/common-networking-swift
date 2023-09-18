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
    case genericError(body: E?, statusCode: Int)
    /// Error thrown when the status code is between 400 and 499, 401 excluded. Will try to map the return body with the generic error model (E).
    /// - parameters
    ///     - body: return type mapped to the generic error model (if possible).
    ///     - statusCode: status code returned by the API.
    case clientError(body: E?, statusCode: Int)
    /// Error thrown when the status code is 401. It usually means that the token has expired.
    case unauthorizedError
    /// Error thrown when the status code is between 500 and 599. Will try to map the return body with the generic error model (E).
    /// - parameters
    ///     - body: return type mapped to the generic error model (if possible).
    ///     - statusCode: status code returned by the API.
    case serverError(body: E?, statusCode: Int)
    /// Error thrown when the response data can not be mapped to the defined type T. Will try to map the return body with the generic error model (E).
    /// - parameters
    ///     - body: return type mapped to the generic error model (if possible).
    ///     - statusCode: status code returned by the API.
    case decodeError(message: String, statusCode: Int)
    /// Error thrown when the server response is null.
    /// - parameters
    ///     - statusCode: status code returned by the API.
    case emptyBodyError(statusCode: Int)
}

extension NetworkError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .genericError(_, let statusCode):
            return "Generic Error: \(statusCode)"
        case .clientError(_, let statusCode):
            return "Client Error: \(statusCode)"
        case .unauthorizedError:
            return "Unauthorized Error"
        case .serverError(_, let statusCode):
            return "Server Error: \(statusCode)"
        case .decodeError(let message, let statusCode):
            return "Decode Error: \(statusCode), \(message)"
        case .emptyBodyError(let statusCode):
            return "Empty body Error: \(statusCode)"
        }
    }
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .genericError(let body, let statusCode):
            return "Generic Error: \(statusCode) \(String(describing: body))"
        case .clientError(let body, let statusCode):
            return "Client Error: \(statusCode) \(String(describing: body))"
        case .unauthorizedError:
            return "Unauthorized Error"
        case .serverError(let body, let statusCode):
            return "Server Error: \(statusCode) \(String(describing: body))"
        case .decodeError(let message, let statusCode):
            return "Decode Error: \(statusCode), \(message)"
        case .emptyBodyError(let statusCode):
            return "Empty body Error: \(statusCode)"
        }
    }
}

/// Object to handle empty body response from APIs
public struct EmptyContent: Decodable {}
