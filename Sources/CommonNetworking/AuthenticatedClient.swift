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

public enum AuthorizationType: String {
    case bearer = "Bearer"
}

public final class AuthenticateClient: ApiClient {
    
    private func buildAuthenticatedRequest(_ request: inout URLRequest, authType: AuthorizationType, accessToken: String?) {
        guard let accessToken else { return }
        request.addValue("\(AuthorizationType.bearer.rawValue) \(accessToken)", forHTTPHeaderField: authType.rawValue)
    }
    
    public override func run<T: Decodable, E: Decodable>(_ request: URLRequest, accessToken: String? = "") async -> ApiResponse<T,E> {
         
        //TODO: add logic that retrive the access token
        
        var authenticatedRequest = request
        buildAuthenticatedRequest(&authenticatedRequest, authType: .bearer, accessToken: accessToken)
        let response: ApiResponse<T,E> = await super.run(request)
        let reAuthResponse = await reAuth(response, request)
        return reAuthResponse ?? response
    }
    
    func reAuth<T: Decodable, E: Decodable>(_ response: ApiResponse<T,E>,
                                            _ request: URLRequest) async -> ApiResponse<T,E>? {
        
        //TODO: add logic that retrive the access token
        let tmp: String? = ""
        guard let refreshToken = tmp else {
            return nil
        }
        
        guard case let .failure(_, _, httpStatusCode) = response else {
            return nil
        }
        
        guard httpStatusCode == 401 else {
            return nil
        }
        
        // TODO
        
        return nil
    }
}
