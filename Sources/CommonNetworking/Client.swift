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

public enum AuthorizationScheme: String {
    case Bearer
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
                
                let response: ApiResponse<T, E> = self.successResponse(from: data) ??
                self.failureResponse(from: data, of: urlResponse, for: httpError)
                continuation.resume(returning: response)
            }.resume()
        }
    }
    
    private func successResponse<T: Decodable, E: Decodable>(from data: Data) -> ApiResponse<T,E>? {
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
        
        guard let obj = try? decoder.decode(T.self, from: data) else {
            return nil
        }

        return .success(response: obj)
    }
    
    private func buildAuthenticatedRequest(_ request: inout URLRequest, authScheme: AuthorizationScheme, accessToken: String?) {
        guard let accessToken else { return }
        request.addValue("\(AuthorizationScheme.Bearer.rawValue) \(accessToken)",
                         forHTTPHeaderField: Headers.authorization.rawValue)
    }
    
    public func run<T: Decodable, E: Decodable>(_ request: URLRequest, accessToken: String) async -> ApiResponse<T,E> {
        var authenticatedRequest = request
        buildAuthenticatedRequest(&authenticatedRequest, authScheme: .Bearer, accessToken: accessToken)
        let response: ApiResponse<T,E> = await run(authenticatedRequest)
        let reAuthResponse = await reAuth(response, authenticatedRequest)
        return reAuthResponse ?? response
    }
    
    func reAuth<T: Decodable, E: Decodable>(_ response: ApiResponse<T,E>,
                                            _ request: URLRequest) async -> ApiResponse<T,E>? {
         
        //TODO
        return nil
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
}
