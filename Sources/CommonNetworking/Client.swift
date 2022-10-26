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

open class ApiClient {
    private let session: URLSession
    
    public init(session: URLSession) {
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
        guard let obj = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }

        return .success(response: obj)
    }
    
    private func failureResponse<T: Decodable, E: Decodable>(from data: Data, of urlResponse: URLResponse?, for error: Error?) -> ApiResponse<T, E> {
        
        let obj = try? JSONDecoder().decode(E.self, from: data)
        return .failure(
            response: obj,
            error: error,
            httpStatusCode: urlResponse?.httpStatusCode
        )
    }
}