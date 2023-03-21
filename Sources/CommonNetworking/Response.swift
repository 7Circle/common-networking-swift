//             ___    ___    _____ __      __  ______
//    o O O   | __|  / _ \  |_   _|\ \    / / |zero12|
//   o        | _|  | (_) |   | |   \ \/\/ /  |mobile|
//  TS__[O]  _|_|_   \___/   _|_|_   \_/\_/   | team |
// {======|_| """ |_|"""""|_|"""""|_|"""""|___|""""""|
//./o--000'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"""`-0--0-'
//
//  Created by Marco Brugnera on 26/10/22.
//

import Foundation

public enum NetworkError<E: Decodable>: Error {
    case genericError(body: E?, statusCode: Int)
    case clientError(body: E?, statusCode: Int)
    case unauthorizedError
    case serverError(body: E?, statusCode: Int)
    case decodeError(message: String, statusCode: Int)
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

public struct EmptyContent: Decodable {}
