//  ______   ______    ______   __     __
// /\  ___\ /\  __ \  /\__  _\ /\ \  _ \ \
// \ \  __\ \ \ \/\ \ \/_/\ \/ \ \ \/ ".\ \
//  \ \_\    \ \_____\   \ \_\  \ \__/".~\_\
//   \/_/     \/_____/    \/_/   \/_/   \/_/
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

extension URL: URLRequestEnricher {
    public func enrich(request: inout URLRequest) {
        request.url = self
    }
}

public func url(_ url: URL, pathComponent: String?, parameters: [String:String?]) -> URL {
    var resultUrl = url
    if let pathComponent {
        resultUrl = resultUrl.appendingPathComponent(pathComponent)
    }
    let queryParameters: [URLQueryItem] = parameters.compactMap({ URLQueryItem(name: $0, value: $1) })
    if !queryParameters.isEmpty, let queryUrl = resultUrl.appending(queryParameters) {
        resultUrl = queryUrl
    }
    return resultUrl
}

public extension URL {
    /// Returns a new URL by adding the query items, or nil if the URL doesn't support it.
    /// URL must conform to RFC 3986.
    func appending(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            // URL is not conforming to RFC 3986 (maybe it is only conforming to RFC 1808, RFC 1738, and RFC 2732)
            return nil
        }
        // append the query items to the existing ones
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
        
        // return the url from new url components
        return urlComponents.url
    }
}
