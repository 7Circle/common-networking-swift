//  ______   ______    ______   __     __
// /\  ___\ /\  __ \  /\__  _\ /\ \  _ \ \
// \ \  __\ \ \ \/\ \ \/_/\ \/ \ \ \/ ".\ \
//  \ \_\    \ \_____\   \ \_\  \ \__/".~\_\
//   \/_/     \/_____/    \/_/   \/_/   \/_/
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

struct TestDataModel: Decodable {
    let data: TestModel
}
