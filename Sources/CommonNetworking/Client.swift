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

public struct NoReply: Codable {}

public enum AuthorizationScheme: String {
    case Bearer
}

struct ErrorModel: Error {
    let message: String
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

open class APIClient {
    private let session: URLSession
    
    public init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    open func run<T: Decodable, E: Decodable>(_ request: URLRequest) async -> ApiResponse<T, E> {
        return await withCheckedContinuation { continuation in
            session.dataTask(with: request) { (data, urlResponse, httpError) in
                guard let data else {
                    continuation.resume(
                        returning: .failure(
                            response: nil,
                            error: httpError,
                            httpStatusCode: urlResponse?.httpStatusCode
                        )
                    )
                    return
                }
                
                let response: ApiResponse<T, E> = self.successResponse(from: data, statusCode: urlResponse?.httpStatusCode ?? 0) ??
                self.failureResponse(from: data, of: urlResponse, for: httpError)
                continuation.resume(returning: response)
            }.resume()
        }
    }
    
    private func successResponse<T: Decodable, E: Decodable>(from data: Data, statusCode: Int) -> ApiResponse<T,E>? {
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

        if statusCode == 204 {
            let model = NoReply()
            if let model = model as? T {
                return .success(response: model)
            } else {
                return .failure(response: nil, error: ErrorModel(message: "Error while parsing empty data"), httpStatusCode: statusCode)
            }
        }
        
        do {
            let obj = try decoder.decode(T.self, from: data)
            return .success(response: obj)
        } catch(let error) {
            return .failure(response: nil, error: error, httpStatusCode: statusCode)
        }
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
    
    private func failureResponse<T: Decodable, E: Decodable>(from data: Data,
                                                             of urlResponse: URLResponse?,
                                                             for error: Error?) -> ApiResponse<T, E> {
        
        let obj = try? JSONDecoder().decode(E.self, from: data)
        return .failure(
            response: obj,
            error: error,
            httpStatusCode: urlResponse?.httpStatusCode
        )
    }
  
    
    
    //TODO: define how to handle 401 retry
    
//    public func run<T: Decodable, E: Decodable>(_ request: URLRequest, settings: APIRequestSettings) async -> ApiResponse<T,E> {
//        let response: ApiResponse<T,E> = await run(request)
//        let reAuthResponse = await reAuth(response, request)
//        return reAuthResponse ?? response
//    }
//
//    func reAuth<T: Decodable, E: Decodable>(_ response: ApiResponse<T,E>,
//                                            _ request: URLRequest) async -> ApiResponse<T,E>? {
//
//        //TODO
//        return nil
//    }
}
