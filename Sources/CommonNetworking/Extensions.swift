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

public protocol URLRequestEnricher {
    func enrich(request: inout URLRequest)
}


@resultBuilder
public struct URLRequestEnricherComposer {
    public static func buildBlock(_ enrichers: URLRequestEnricher...) -> [URLRequestEnricher] {
        enrichers
    }
}

public extension URLResponse {
    var httpStatusCode: Int {
        (self as? HTTPURLResponse)?.statusCode ?? -1
    }
}

public extension URLRequest {
    mutating func update(@URLRequestEnricherComposer _ enricherComposer: () -> [URLRequestEnricher]) {
        let enrichers = enricherComposer()
        execute(enrichers: enrichers, on: &self)
    }
    
    func update(@URLRequestEnricherComposer _ enricherComposer: () -> [URLRequestEnricher]) -> URLRequest {
        var updatedRequest = self
        let enrichers = enricherComposer()
        execute(enrichers: enrichers, on: &updatedRequest)
        return updatedRequest
    }
}

extension URL: URLRequestEnricher {
    public func enrich(request: inout URLRequest) {
        request.url = self
    }
}

public func url(_ url: URL) -> URL {
    url
}
