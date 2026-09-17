//  ______   ______    ______   __     __
// /\  ___\ /\  __ \  /\__  _\ /\ \  _ \ \
// \ \  __\ \ \ \/\ \ \/_/\ \/ \ \ \/ ".\ \
//  \ \_\    \ \_____\   \ \_\  \ \__/".~\_\
//   \/_/     \/_____/    \/_/   \/_/   \/_/
//
//  Created by Marco Brugnera on 26/10/22.
//

import Foundation

/// Common headers to be used in the requests.
public enum Headers: String {
    case acceptLanguage = "Accept-Language"
    case apiKey = "x-api-key"
    case authorization = "Authorization"
    case contentType = "Content-Type"
    case userAgent = "User-Agent"
}
