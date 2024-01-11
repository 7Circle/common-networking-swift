//  ______   ______    ______   __     __
// /\  ___\ /\  __ \  /\__  _\ /\ \  _ \ \
// \ \  __\ \ \ \/\ \ \/_/\ \/ \ \ \/ ".\ \
//  \ \_\    \ \_____\   \ \_\  \ \__/".~\_\
//   \/_/     \/_____/    \/_/   \/_/   \/_/
//
//  Created by Marco Brugnera on 26/10/22.
//

import Foundation

/// List of all the Authorization schemes managed by the library
public enum AuthorizationScheme: String {
    case Bearer
}

/// Defines the settings for an HTTP request
public struct APIRequestSettings {
    let url: URL
    let urlPathComponent: String?
    let urlQueryParameters: [String:String]?
    let httpBody: Data?
    let httpMethod: HTTPMethod
    let httpHeaderFields: [String:String]

    /// Creates a new APIRequestSettings
    /// - Parameters:
    ///     - url: base URL of the request
    ///     - urlPathComponent: path components to add to the url
    ///     - urlQueryParameters: dictionary containing all the query parameters of the request
    ///     - httpBody: body of the request
    ///     - httpMethod: HTTP method of the request
    ///     - httpHeaderFields: dictionary containing all the HTTP header fields of the request
    public init(url: URL,
                urlPathComponent: String?,
                urlQueryParameters: [String:String]? = nil,
                httpBody: Data? = nil,
                httpMethod: HTTPMethod,
                httpHeaderFields: [String:String] = [:]) {
        self.url = url
        self.urlPathComponent = urlPathComponent
        self.urlQueryParameters = urlQueryParameters
        self.httpBody = httpBody
        self.httpMethod = httpMethod
        self.httpHeaderFields = httpHeaderFields
    }
}

/// Client that runs the API requests. A single APIClient can use a single generic error (E) model.
/// - Generics:
///     - E: type of the error returned by the APIs
public struct APIClient<E: Decodable> {
    private let session: URLSession
    private let defaultHeaders: [String: String]

    /// - Parameters:
    ///     - session: URLSession instance
    ///     - defaultHeaders: a Key Value map with the headers
    public init(session: URLSession = URLSession(configuration: .default), defaultHeaders: [String: String] = [:]) {
        self.session = session
        self.defaultHeaders = defaultHeaders
    }

    /// Creates a task that retrieves the contents of a URL based on the specific URL request object.
    ///
    /// **Note**: Creates and resumes an URLSessionDataTask internally
    ///
    /// **Note**: Every header set in the request will override any default header set in the APIClient initialisation.
    ///
    /// - Parameters:
    ///     - request: A URLRequest object that provides the URL, cache policy, request type, body data or body stream, and so on.
    ///
    /// - Returns: Object decoded as T if the API returns a success code and the mapping is successful.
    ///
    /// - Throws: ``NetworkError``. If the type of error supports the mapping the error will contain an instance of E mapped with the error data from the API.
    public func run<T: Decodable>(_ request: URLRequest) async throws -> T {
        var completeRequest = request
        completeRequest.allHTTPHeaderFields = defaultHeaders.merging(request.allHTTPHeaderFields ?? [:]) { _,requestValue in requestValue }
        return try await withCheckedThrowingContinuation { continuation in
            session.dataTask(with: completeRequest) { (data, urlResponse, httpError) in
                let statusCode = getStatusCode(urlResponse)
                if let networkError: NetworkError<E> = checkFailure(from: data, statusCode: statusCode) {
                    continuation.resume(throwing: networkError)
                    return
                }

                guard let data else {
                    continuation.resume(throwing: NetworkError<E>.invalidResponseBodyError(statusCode: statusCode))
                    return
                }

                guard !data.isEmpty else {
                    if let response: T = EmptyContent() as? T {
                        continuation.resume(returning: response)
                    } else {
                        continuation.resume(throwing: NetworkError<E>.emptyBodyError(message: "Expected to find \(T.self) but found no content body instead", statusCode: statusCode))
                    }
                    return
                }

                do {
                    let response: T = try handleResponse(from: data)
                    continuation.resume(returning: response)
                } catch {
                    continuation.resume(throwing: NetworkError<E>.decodeError(error, statusCode: statusCode))
                }
            }.resume()
        }
    }

    /// Creates a task that retrieves the contents of a URL based on the specific URL request object.
    ///
    /// Note: Creates and resumes an URLSessionDataTask internally
    ///
    /// - Parameters:
    ///     - request: A ``APIRequestSettings`` object that provides all the information needed to perform the REST request.
    ///
    /// - Returns: Object decoded as T if the API returns a success code and the mapping is successfull.
    ///
    /// - Throws: ``NetworkError``. If the type of error supports the mapping the error will contain an instance of E mapped with the error data from the API.
    public func run<T: Decodable>(_ request: APIRequestSettings) async throws -> T {
        try await run(buildRequest(request))
    }
    
    internal func handleResponse<T: Decodable>(from data: Data) throws -> T {
        let formatter = DateFormatter()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container,
                debugDescription: "Cannot decode date string \(dateString)")
        }

        return try decoder.decode(T.self, from: data)
    }


    internal func buildAuthenticatedRequest(_ request: inout URLRequest, authScheme: AuthorizationScheme, accessToken: String?) {
        guard let accessToken else { return }
        request.addValue("\(AuthorizationScheme.Bearer.rawValue) \(accessToken)",
                         forHTTPHeaderField: Headers.authorization.rawValue)
    }

    /// Creates a URLRequest starting from a ``APIRequestSettings`` object.
    /// - parameters:
    ///     - settings: ``APIRequestSettings`` with all the information to perform the REST request
    ///
    /// - returns: the URLRequest that represents the specified settings.
    public func buildRequest(_ settings: APIRequestSettings) -> URLRequest {
        var request = URLRequest(url: url(settings.url, pathComponent: settings.urlPathComponent, parameters: settings.urlQueryParameters ?? [:]))
        request.httpMethod = settings.httpMethod.rawValue
        request.httpBody = settings.httpBody
        request.allHTTPHeaderFields = settings.httpHeaderFields
        return request
    }
    
    internal func checkFailure<U: Decodable>(from data: Data?, statusCode: Int) -> NetworkError<U>? {
        switch statusCode {
        case 200..<399:
            return nil
        case 400..<499:
            guard let data else {
                return .clientError(body: nil, statusCode: statusCode, parseResult: .invalidResponseBodyError)
            }
            do {
                return try .clientError(body: getErrorBody(from: data), statusCode: statusCode, parseResult: .success)
            } catch {
                return .clientError(body: nil, statusCode: statusCode, parseResult: .decodeError(message: NetworkError<U>.parseDecodingError(error: error)))
            }
        case 500..<599:
            guard let data else {
                return .serverError(body: nil, statusCode: statusCode, parseResult: .invalidResponseBodyError)
            }
            do {
                return try .serverError(body: getErrorBody(from: data), statusCode: statusCode, parseResult: .success)
            } catch {
                return .serverError(body: nil, statusCode: statusCode, parseResult: .decodeError(message: NetworkError<U>.parseDecodingError(error: error)))
            }
        default:
            guard let data else {
                return .genericError(body: nil, statusCode: statusCode, parseResult: .invalidResponseBodyError)
            }
            do {
                return try .genericError(body: getErrorBody(from: data), statusCode: statusCode, parseResult: .success)
            } catch {
                return .genericError(body: nil, statusCode: statusCode, parseResult: .decodeError(message: NetworkError<U>.parseDecodingError(error: error)))
            }
        }
    }
    
    private func getErrorBody<U: Decodable>(from data: Data) throws -> U? {
        try JSONDecoder().decode(U.self, from: data)
    }
    
    internal func getStatusCode(_ response: URLResponse?) -> Int {
        (response as? HTTPURLResponse)?.statusCode ?? -1
    }
}
