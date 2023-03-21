import XCTest
import Mocker
@testable import CommonNetworking

final class CommonNetworkingTests: XCTestCase {

    private var client: APIClient<TestModel>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        client = APIClient<TestModel>()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        Mocker.removeAll()
    }

    // MARK: Client - getStatusCode

    private func testGetStatusCode(statusCode: Int) async {
        let testExpectation = XCTestExpectation(description: "Status code: \(statusCode)")
        let serviceURL: URL = URL(string: "https://www.zero12.it")!
        Mock(url: serviceURL,
             dataType: .json,
             statusCode: statusCode,
             data: [.get: Data()])
        .register()

        let (_, response) = try! await mockDataTask(url: serviceURL)
        let responseStatusCode = client.getStatusCode(response)
        XCTAssertEqual(responseStatusCode, statusCode)
        testExpectation.fulfill()
    }


    func testGetStatusCodeForURLResponseWithStatusCodeEqual100() async {
        await testGetStatusCode(statusCode: 100)
    }

    func testGetStatusCodeForURLResponseWithStatusCodeEqual200() async {
        await testGetStatusCode(statusCode: 200)
    }

    func testGetStatusCodeForURLResponseWithStatusCodeEqual300() async {
        await testGetStatusCode(statusCode: 300)
    }

    func testGetStatusCodeForURLResponseWithStatusCodeEqual400() async {
        await testGetStatusCode(statusCode: 400)
    }

    func testGetStatusCodeForURLResponseWithStatusCodeEqual500() async {
        await testGetStatusCode(statusCode: 500)
    }

    func testGetStatusCodeWithNilUrlResponse() {
        let statusCode = client.getStatusCode(nil)
        XCTAssertEqual(statusCode, -1)
    }

    private func mockDataTask(url: URL) async throws -> (Data, URLResponse){
        return try await URLSession.shared.data(from: url)
    }

    // MARK: Client - checkFailure
    private func testCheckFailure(statusCode: Int) async -> (Data, URLResponse) {
        let mockModel: TestError? = mockedDataSource(fileName: "error_model")
        let serviceURL: URL = URL(string: "https://www.zero12.it")!
        Mock(url: serviceURL,
             dataType: .json,
             statusCode: statusCode,
             data: [.get: try! JSONEncoder().encode(mockModel)])
        .register()

        return try! await mockDataTask(url: serviceURL)
    }

    func testCheckFailureForASuccessedAPIResponse() async {
        let testExpectation = XCTestExpectation(description: "Check failure return: nil")
        let (data, _) = await testCheckFailure(statusCode: 200)
        let checkFailure: NetworkError<TestError>? = client.checkFailure(from: data, statusCode: 200)
        XCTAssertNil(checkFailure)
        testExpectation.fulfill()
    }

    func testCheckFailureForAFailureAPIResponseWithStatusCode400() async {
        let testExpectation = XCTestExpectation(description: "Check failure return: .clientError")
        let mockStatusCode = 400
        let (data, _) = await testCheckFailure(statusCode: mockStatusCode)
        let checkFailure: NetworkError<TestError>? = client.checkFailure(from: data, statusCode: mockStatusCode)
        XCTAssertNotNil(checkFailure)
        switch checkFailure {
        case .clientError(let body, let statusCode):
            XCTAssertEqual(body!.message, "generic error")
            XCTAssertEqual(statusCode, mockStatusCode)
            testExpectation.fulfill()
        default:
            XCTFail("testExpectationThirdAPICall expectarion not satisied!")
        }
    }

    func testCheckFailureForAFailureAPIResponseWithStatusCode500() async {
        let testExpectation = XCTestExpectation(description: "Check failure return: .serverError")
        let mockStatusCode = 500
        let (data, _) = await testCheckFailure(statusCode: mockStatusCode)
        let checkFailure: NetworkError<TestError>? = client.checkFailure(from: data, statusCode: mockStatusCode)
        XCTAssertNotNil(checkFailure)
        switch checkFailure {
        case .serverError(let body, let statusCode):
            XCTAssertEqual(body!.message, "generic error")
            XCTAssertEqual(statusCode, mockStatusCode)
            testExpectation.fulfill()
        default:
            XCTFail("testExpectationForthAPICall expectarion not satisied!")
        }
    }

    func testCheckFailureForAFailureAPIResponseWithStatusCodeNotValid() async {
        let testExpectation = XCTestExpectation(description: "Check failure return: .genericError")
        let mockStatusCode = 1000
        let (data, _) = await testCheckFailure(statusCode: mockStatusCode)
        let checkFailure: NetworkError<TestError>? = client.checkFailure(from: data, statusCode: mockStatusCode)
        XCTAssertNotNil(checkFailure)
        switch checkFailure {
        case .genericError(let body, let statusCode):
            XCTAssertEqual(body!.message, "generic error")
            XCTAssertEqual(statusCode, mockStatusCode)
            testExpectation.fulfill()
        default:
            XCTFail("testExpectationFifthAPICall expectarion not satisied!")
        }
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
