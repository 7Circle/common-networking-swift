import XCTest
import Mocker
@testable import CommonNetworking

final class CommonNetworkingTests: XCTestCase {

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        Mocker.removeAll()
    }

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
             requestError: TestError(message: ""))
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

    func testCheckFailure() {
        let client = APIClient<TestModel>()
        let testExpectationFirstAPICall = XCTestExpectation(description: "Check failure return: nil")
        let testExpectationSecondAPICall = XCTestExpectation(description: "Check failure return: nil")
        let testExpectationThirdAPICall = XCTestExpectation(description: "Check failure return: .clientError")
        let testExpectationForthAPICall = XCTestExpectation(description: "Check failure return .serverError")
        let testExpectationFifthAPICall = XCTestExpectation(description: "Check failure return: .genericError")
        let testExpectationSixthAPICall = XCTestExpectation(description: "Status code: -1")

        let mockModel: TestError? = mockedDataSource(fileName: "error_model")

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
             data: [.get: try! JSONEncoder().encode(mockModel)])
        .register()

        let serviceZero12WorkWithUsURL: URL = URL(string: "https://www.zero12.it/lavora-con-noi/")!
        Mock(url: serviceZero12WorkWithUsURL,
             dataType: .json,
             statusCode: 500,
             data: [.get: try! JSONEncoder().encode(mockModel)])
        .register()

        let serviceZero12URL: URL = URL(string: "https://www.zero12.it")!
        Mock(url: serviceZero12URL,
             dataType: .json,
             statusCode: 1000,
             data: [.get: try! JSONEncoder().encode(mockModel)])
        .register()

        let serviceZero12PackURL: URL = URL(string: "https://www.zero12.it/pack/")!
        Mock(url: serviceZero12PackURL,
             dataType: .json,
             statusCode: -1,
             data: [.get: try! JSONEncoder().encode(mockModel)],
             requestError: TestError(message: ""))
        .register()

        URLSession.shared.dataTask(with: serviceZero12ContactsURL) { (data, urlresponse, err) in
            let checkFailure: NetworkError<TestError>? = client.checkFailure(from: data, statusCode: 200)
            XCTAssertNil(checkFailure)
            testExpectationFirstAPICall.fulfill()
        }.resume()

        URLSession.shared.dataTask(with: serviceZero12BlogURL) { (data, urlresponse, err) in
            let checkFailure: NetworkError<TestError>? = client.checkFailure(from: data, statusCode: 300)
            XCTAssertNil(checkFailure)
            testExpectationSecondAPICall.fulfill()
        }.resume()

        URLSession.shared.dataTask(with: serviceZero12ServicesURL) { (data, urlresponse, err) in
            let mockStatusCode = 400
            let checkFailure: NetworkError<TestError>? = client.checkFailure(from: data, statusCode: mockStatusCode)
            XCTAssertNotNil(checkFailure)
            switch checkFailure {
            case .clientError(let body, let statusCode):
                XCTAssertEqual(body, mockModel)
                XCTAssertEqual(statusCode, mockStatusCode)
                testExpectationThirdAPICall.fulfill()
            default:
                XCTFail("testExpectationThirdAPICall expectarion not satisied!")
            }
        }.resume()

        URLSession.shared.dataTask(with: serviceZero12WorkWithUsURL) { (data, urlresponse, err) in
            let mockStatusCode = 500
            let checkFailure: NetworkError<TestError>? = client.checkFailure(from: data, statusCode: mockStatusCode)
            XCTAssertNotNil(checkFailure)
            switch checkFailure {
            case .serverError(let body, let statusCode):
                XCTAssertEqual(body, mockModel)
                XCTAssertEqual(statusCode, mockStatusCode)
                testExpectationForthAPICall.fulfill()
            default:
                XCTFail("testExpectationForthAPICall expectarion not satisied!")
            }
        }.resume()

        URLSession.shared.dataTask(with: serviceZero12URL) { (data, urlresponse, err) in
            let mockStatusCode = 1000
            let checkFailure: NetworkError<TestError>? = client.checkFailure(from: data, statusCode: mockStatusCode)
            XCTAssertNotNil(checkFailure)
            switch checkFailure {
            case .genericError(let body, let statusCode):
                XCTAssertEqual(body, mockModel)
                XCTAssertEqual(statusCode, mockStatusCode)
                testExpectationFifthAPICall.fulfill()
            default:
                XCTFail("testExpectationFifthAPICall expectarion not satisied!")
            }
        }.resume()

        URLSession.shared.dataTask(with: serviceZero12PackURL) { (data, urlresponse, err) in
            let mockStatusCode = -1
            let checkFailure: NetworkError<TestError>? = client.checkFailure(from: data, statusCode: mockStatusCode)
            XCTAssertNotNil(checkFailure)
            switch checkFailure {
            case .genericError(let body, let statusCode):
                XCTAssertNil(body)
                XCTAssertEqual(statusCode, mockStatusCode)
                testExpectationSixthAPICall.fulfill()
            default:
                XCTFail("testExpectationSixthAPICall expectarion not satisied!")
            }
        }.resume()

        let testExpectations: [XCTestExpectation] = [testExpectationFirstAPICall,
                                                     testExpectationSecondAPICall,
                                                     testExpectationThirdAPICall,
                                                     testExpectationForthAPICall,
                                                     testExpectationFifthAPICall,
                                                     testExpectationSixthAPICall]
        wait(for: testExpectations, timeout: 5.0)
    }

    //MARK: Utils
    private func mockedDataSource<T: Codable>(fileName: String) -> T? {
        let url = Bundle.module.url(forResource: fileName,
                                    withExtension: "json",
                                    subdirectory: "Mocks")!
        let data = try! Data(contentsOf: url)
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
