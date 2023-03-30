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

struct TestError: Error, Codable, Equatable {
    let message: String
}

struct TestModel: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case dateFirstAvailability = "dateFirstAvailability"
        case baseUrl = "base_url"
    }

    let id: Int
    let dateFirstAvailability: Date
    let baseUrl: String
}
