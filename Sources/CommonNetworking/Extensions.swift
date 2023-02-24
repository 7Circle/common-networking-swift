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

public func url(_ url: URL, pathComonent: String?, parameters: [String:String?]?) -> URL {
    guard let parameters else { return url }
    var queryParameters: [URLQueryItem] = []
    parameters.forEach { (key: String, value: String?) in
        queryParameters.append(URLQueryItem(name: key, value: value))
    }

    if let pathComonent  {
        if !queryParameters.isEmpty {
            return url.appendingPathComponent(pathComonent).appending(queryParameters)!
        } else {
            return url.appendingPathComponent(pathComonent)
        }
    } else {
        if !queryParameters.isEmpty {
            return url.appending(queryParameters)!
        } else {
            return url
        }
    }
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
