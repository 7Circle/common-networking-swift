//                                     _      ___              _
//     ___    ___      _ _    ___     / |    |_  )     o O O  | |_     ___    __ _    _ __
//    |_ /   / -_)    | '_|  / _ \    | |     / /     o       |  _|   / -_)  / _` |  | '  \
//   _/__|   \___|   _|_|_   \___/   _|_|_   /___|   TS__[O]  _\__|   \___|  \__,_|  |_|_|_|
// _|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""| {======|_|"""""|_|"""""|_|"""""|_|"""""|
// "`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'./o--000'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'
//
//  Created by Marco Brugnera on 26/10/22.
//

import Foundation

//public struct Header {
//    let key: String
//    let value: String
//}
//
//extension Header: URLRequestEnricher {
//    public func enrich(request: inout URLRequest) {
//        var existingHeaders = request.allHTTPHeaderFields ?? [:]
//        existingHeaders[key] = value
//        request.allHTTPHeaderFields = existingHeaders
//    }
//}
//
//@resultBuilder
//public struct HeadersBuilder {
//    public static func buildBlock(_ headers: Header...) -> [Header] {
//        headers
//    }
//}
//
//public func headers(@HeadersBuilder _ builder: () -> [Header]) -> [String: String] {
//    builder().reduce(into: [String: String]()) { (partialResult: inout [String: String], header: Header) in
//        partialResult[header.key] = header.value
//    }
//}
//
//extension Dictionary: URLRequestEnricher where Key == String, Value == String {
//    public func enrich(request: inout URLRequest) {
//        let currentHeaderFields = request.allHTTPHeaderFields ?? [:]
//        request.allHTTPHeaderFields = currentHeaderFields.merging(self) { $1 }
//    }
//}
//
//extension Header {
//    public static func authorization(type: AuthorizationType,
//                                     value: String) -> Header {
//        Header(key: Headers.authorization.rawValue,
//               value: "\(type.rawValue.capitalized) \(value)")
//    }
//}

public enum Headers: String {
    case userAgent = "User-Agent"
    case authorization = "Authorization"
    case contentType = "Content-Type"
}
