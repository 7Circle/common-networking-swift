import XCTest
import Mocker
@testable import CommonNetworking

enum TestError: Error {
    case generic
}

struct TestModel: Decodable {}

final class CommonNetworkingTests: XCTestCase {

    // MARK: Client
    func testGetStatusCode() {
        let client = APIClient<TestModel>()
        let testExpectationFirstAPICall = XCTestExpectation(description: "Status code: 100")
        let testExpectationSecondAPICall = XCTestExpectation(description: "Status code: 200")
        let testExpectationThirdAPICall = XCTestExpectation(description: "Status code: 300")
        let testExpectationForthAPICall = XCTestExpectation(description: "Status code: 400")
        let testExpectationFifthAPICall = XCTestExpectation(description: "Status code: 500")
        let testExpectationSixthAPICall = XCTestExpectation(description: "Status code: -1")

        let serviceZero12URL: URL = URL(string: "https://www.zero12.it")!
        Mock(url: serviceZero12URL,
             dataType: .json,
             statusCode: 100,
             data: [.get: Data()])
        .register()

        let serviceZero12ContactsURL: URL = URL(string: "https://www.zero12.it/contatti/")!
        Mock(url: serviceZero12ContactsURL,
             dataType: .json,
             statusCode: 200,
             data: [.get: Data()])
        .register()

        let serviceZero12BlogURL: URL = URL(string: "https://www.zero12.it/blog/")!
        Mock(url: serviceZero12BlogURL,
             dataType: .json,
             statusCode: 300,
             data: [.get: Data()])
        .register()

        let serviceZero12ServicesURL: URL = URL(string: "https://www.zero12.it/servizi/")!
        Mock(url: serviceZero12ServicesURL,
             dataType: .json,
             statusCode: 400,
             data: [.get: Data()])
        .register()

        let serviceZero12WorkWithUsURL: URL = URL(string: "https://www.zero12.it/lavora-con-noi/")!
        Mock(url: serviceZero12WorkWithUsURL,
             dataType: .json,
             statusCode: 500,
             data: [.get: Data()])
        .register()

        let serviceZero12PackURL: URL = URL(string: "https://www.zero12.it/pack/")!
        Mock(url: serviceZero12PackURL,
             dataType: .json,
             statusCode: -1,
             data: [.get: Data()],
             requestError: TestError.generic)
        .register()

        URLSession.shared.dataTask(with: serviceZero12URL) { (data, urlresponse, err) in
            let statusCode: Int = client.getStatusCode(urlresponse)
            XCTAssertEqual(statusCode, 100)
            testExpectationFirstAPICall.fulfill()
        }.resume()

        URLSession.shared.dataTask(with: serviceZero12ContactsURL) { (data, urlresponse, err) in
            let statusCode = client.getStatusCode(urlresponse)
            XCTAssertEqual(statusCode, 200)
            testExpectationSecondAPICall.fulfill()
        }.resume()

        URLSession.shared.dataTask(with: serviceZero12BlogURL) { (data, urlresponse, err) in
            let statusCode = client.getStatusCode(urlresponse)
            XCTAssertEqual(statusCode, 300)
            testExpectationThirdAPICall.fulfill()
        }.resume()

        URLSession.shared.dataTask(with: serviceZero12ServicesURL) { (data, urlresponse, err) in
            let statusCode = client.getStatusCode(urlresponse)
            XCTAssertEqual(statusCode, 400)
            testExpectationForthAPICall.fulfill()
        }.resume()

        URLSession.shared.dataTask(with: serviceZero12WorkWithUsURL) { (data, urlresponse, err) in
            let statusCode: Int = client.getStatusCode(urlresponse)
            XCTAssertEqual(statusCode, 500)
            testExpectationFifthAPICall.fulfill()
        }.resume()

        URLSession.shared.dataTask(with: serviceZero12PackURL) { (data, urlresponse, err) in
            let statusCode: Int = client.getStatusCode(urlresponse)
            XCTAssertEqual(statusCode, -1)
            testExpectationSixthAPICall.fulfill()
        }.resume()

        let testExpectations: [XCTestExpectation] = [testExpectationFirstAPICall,
                                                     testExpectationSecondAPICall,
                                                     testExpectationThirdAPICall,
                                                     testExpectationForthAPICall,
                                                     testExpectationFifthAPICall,
                                                     testExpectationSixthAPICall]
        wait(for: testExpectations, timeout: 5.0)
    }
}
