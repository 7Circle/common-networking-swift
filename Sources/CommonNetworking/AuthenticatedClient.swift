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

public final class AuthenticateClient: ApiClient {
    
    private func buildAuthenticatedRequest(_ request: inout URLRequest, authScheme: AuthorizationScheme, accessToken: String?) {
        guard let accessToken else { return }
        request.addValue("\(AuthorizationScheme.Bearer.rawValue) \(accessToken)",
                         forHTTPHeaderField: Headers.authorization.rawValue)
    }
    
    public func run<T: Decodable, E: Decodable>(_ request: URLRequest, accessToken: String) async -> ApiResponse<T,E> {
        var authenticatedRequest = request
        buildAuthenticatedRequest(&authenticatedRequest, authScheme: .Bearer, accessToken: accessToken)
        let response: ApiResponse<T,E> = await super.run(authenticatedRequest)
        let reAuthResponse = await reAuth(response, authenticatedRequest)
        return reAuthResponse ?? response
    }
    
    func reAuth<T: Decodable, E: Decodable>(_ response: ApiResponse<T,E>,
                                            _ request: URLRequest) async -> ApiResponse<T,E>? {
         
        //TODO
        return nil
    }
}
