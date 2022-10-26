//                                     _      ___              _
//     ___    ___      _ _    ___     / |    |_  )     o O O  | |_     ___    __ _    _ __
//    |_ /   / -_)    | '_|  / _ \    | |     / /     o       |  _|   / -_)  / _` |  | '  \
//   _/__|   \___|   _|_|_   \___/   _|_|_   /___|   TS__[O]  _\__|   \___|  \__,_|  |_|_|_|
// _|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""| {======|_|"""""|_|"""""|_|"""""|_|"""""|
// "`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'./o--000'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'
//
//  Created by Marco Brugnera on 26/10/22.
//
//
//

import Foundation

@resultBuilder
public struct URLRequestBuilder {
    public static func buildBlock(_ enrichers: URLRequestEnricher...) -> URLRequest {
        var startingRequest = URLRequest(url: URL(string: "https://")!)
        execute(enrichers: enrichers, on: &startingRequest)
        return startingRequest
    }
}

public func urlRequest(@URLRequestBuilder _ builder: () throws -> URLRequest) rethrows -> URLRequest {
    try builder()
}

internal func execute(enrichers: [URLRequestEnricher], on request: inout URLRequest) {
    for enricher in enrichers {
        enricher.enrich(request: &request)
    }
}
