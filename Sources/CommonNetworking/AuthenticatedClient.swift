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
    case bearer
}

public final class AuthenticateClient: ApiClient {
    
    public override func run<T: Decodable, E: Decodable>(_ request: URLRequest) async -> ApiResponse<T,E> {
        
        let accessToken = "eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ.hf2UAZC6EnxNnJ9JzuwvaRJoGdoWWD41b835HnSSaB9n-nUfn81rWayYVBZ8QUyekM5ZpvTJbCvRJYvvHffR5c-EK_8n9oCLEvMTzd7uvo1-GcXv5pm53YSDZJHrNsZKllXQGeO30hDitN2gLlLW_ZzlEcvK7-lIhhxNDHV3m1U6RL9vdql1khnT9whZbsQIICVzwrmfS9WfqFqv9cHchClgyFsdrfdmQOzGZPNY8CcKznFNxWiKEIhR1xKFHZeaCzYpc0l1e4cSeXGsDCzlcZgUZeok-n_72IQCZBOhuQxLXGZ6_yxXsHdupJo7W4v0B5Nq0JEEojTwE4_lJucXWA.MLzCIPs-XxV64HYU.3kIMZCRK6lhmpejPnIanOBt6AsGDlhLZMxVKfL2LfbNMBPLD0lsRrDSx3Lhdl4ThNeYv4Ll73UVANjqb0071ke0H_DqmjdGy0-W7pu3SROltQOjpAaBEMHF3xwLztVxnOMztCZeQBmJ6FC-n_6FuRC84SrQ60yLH7qFtDqcPwVJ_XFNKo9lbZqix0zhahD6rNqSra7qUqIp7XHLOz1Dj2aV8_5SQXf8qTGcba7pX1f8NBy4Ykvo7k3QwP70jhpWKW7Yt4JfFGxC8rxtl2XLANrHJwSAACG4xGGyy-roqc_sOWveIb20nHVgvo0MohkH3_q8fCqbIyGLxRvzYK5pUI3IM6TQ0TNWYTCIbIIdERnHA2vytXopWnKqgC5iS60eTs4NZVK9c7MT2byyBx1clGapUo0yEt4qv9N7ca6uXmZw1y3MnCttCDWnuUIhfd_-9jb57GGuAc7aKT0S81TPYO-920F0jZUJmWwRHJQVnyJQ-t0mFxiRw0zgml27jAZm5-yufoB5znRy5t17XaELzNzrVFbI-98ovmBxOp5McZIzvYeyF6ZaZBpkzLA3skFFUGR1lIDPL7Tq3OxZ8oNjBGGzsdDVPc-kw_xEcnPnhHLc60LoXFbg7dwKLn8sAIRlPygNDfwfqyNEuaLfRuZ-ydzzwB3syrQaOA_L5SP4Utt0XWRQsxzFJq-ZSlOLin6Zz-eklveEhUQVKhZYZH2mkQHMyWUKYV1elrQPKDlEm6u2GogZSvwv46x3dPauBCdmPISy6LPTGzHbT_XDdjAMJnU4M7QrBXORXl9iGHEvf9eeR5hLvQa7Uli000dX2sekasNrIU2iCy7SE0s77q2NUonTQLRjoQkDGvK9Djfxatrm6tf9sl8iM-zsO26FfW1EPWe2gjM5laNsRS-oXXyTKbZ6i5hyYi8fjwy59hVLFRi_FQAbcwmQq6DB8TvCHV5JCFD-xhxwAkRv69nPLETtOvlTKwdxPV-Y5QgOUfkKZIauRk0tECJ1T8vZxruW-e9jE9teMOcPqv1VdagNUv6wh8NmxuQBnjq2MMGeq9SVvs496r1GaQS9HYaRs4ZlRBm4yj5zd3tabSJBuj1MXjlPun2XuAl_NiIWNbFuhgkj9uVlWHBRTZ2LUuJhVGzpimPjsPbM7xydZpSeVsgUmc6cMcicNoLnCihYqJwxIAc9VcaG2eCooetmGIQxjZ_0H4UUIWVBJUHg3kDHgy8eJUmmSaN5KOhbsl3ZeBoDn1phb99QZOQvelJ-34MrWHlvueEjCFAgSAoBam5D6JjccbVC6yXchTklAsleQ-pcoq7VcolKskFJPJmL9MT0vzxk33tLbFmHY.QrPOCrIpTX_A7frEt91JRw" //TODO: add logic that retrive the access token
        
        let authenticateRequest = request.update {
            headers {
                Header.authorization(type: .bearer, value: accessToken)
            }
        }
        
        let response: ApiResponse<T,E> = await super.run(authenticateRequest)
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
