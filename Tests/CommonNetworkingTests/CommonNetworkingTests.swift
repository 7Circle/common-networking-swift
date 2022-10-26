import XCTest
@testable import CommonNetworking

final class CommonNetworkingTests: XCTestCase {

    private struct Person: Codable, Equatable {
        
        let name: String
        let surname: String
    }

    private struct PersonError: Codable, Equatable {
        
        let error: String
    }
    
    
    func testMy() {
        let session = URLSession(configuration: .default)
        let client = AuthenticateClient(session: session)
        
        Task {
            let tmp: ApiResponse<Person, PersonError> = await client.run(urlRequest { url(URL(string: "https://api-qas.mypragma.cloud/interventions?page=1&pageSize=100")!)}) as ApiResponse<Person, PersonError>
            
            print("")
        }
    }
    
    
}
