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

public enum AuthorizationScheme: String {
    case Bearer
}

public struct APIRequestSettings {
    let url: URL
    let urlPathComponent: String?
    let urlQueryParameters: [String:String]?
    let httpBody: Data?
    let httpMethod: HTTPMethod
    let httpHeaderFields: [String:String]
    
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

public struct APIClient<E: Decodable> {
    private let session: URLSession
    
    public init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    public func run<T: Decodable>(_ request: URLRequest) async throws -> T? {
        return try await withCheckedThrowingContinuation { continuation in
            session.dataTask(with: request) { (data, urlResponse, httpError) in
                let statusCode = getStatusCode(urlResponse)
                if let networkError: NetworkError<E> = checkFailure(from: data, statusCode: statusCode) {
                    continuation.resume(throwing: networkError)
                    return
                }
                
                guard let data else {
                    continuation.resume(throwing: NetworkError<E>.emptyBodyError(statusCode: statusCode))
                    return
                }

                do {
                    let response: T = try handleResponse(from: data)
                    continuation.resume(returning: response)
                } catch {
                    continuation.resume(throwing: NetworkError<E>.decodeError(message: error.localizedDescription,
                                                                              statusCode: statusCode))
                }
            }.resume()
        }
    }
    
    private func handleResponse<T: Decodable>(from data: Data) throws -> T {
        let formatter = DateFormatter()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
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
    
    private func buildAuthenticatedRequest(_ request: inout URLRequest, authScheme: AuthorizationScheme, accessToken: String?) {
        guard let accessToken else { return }
        request.addValue("\(AuthorizationScheme.Bearer.rawValue) \(accessToken)",
                         forHTTPHeaderField: Headers.authorization.rawValue)
    }
    
    public func buildRequest(_ settings: APIRequestSettings) -> URLRequest {
        var request = URLRequest(url: url(settings.url, pathComponent: settings.urlPathComponent, parameters: settings.urlQueryParameters ?? [:]))
        request.httpMethod = settings.httpMethod.rawValue
        request.httpBody = settings.httpBody
        request.allHTTPHeaderFields = settings.httpHeaderFields
        return request
    }
    
    private func checkFailure<E: Decodable>(from data: Data?, statusCode: Int) -> NetworkError<E>? {
        switch statusCode {
        case 200..<399:
            return nil
        case 400..<499:
            return .clientError(body: getErrorBody(from: data), statusCode: statusCode)
        case 500..<599:
            return .serverError(body: getErrorBody(from: data), statusCode: statusCode)
        default:
            return .genericError(body: getErrorBody(from: data), statusCode: statusCode)
        }
    }
    
    private func getErrorBody<E: Decodable>(from data: Data?) -> E? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(E.self, from: data)
    }
    
    private func getStatusCode(_ response: URLResponse?) -> Int {
        (response as? HTTPURLResponse)?.statusCode ?? -1
    }
}
