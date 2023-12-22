import XCTest
import Mocker
@testable import CommonNetworking

final class CommonNetworkingTests: XCTestCase {

    private var client: APIClient<TestError>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        client = APIClient<TestError>(session: URLSession(configuration: configuration))
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        Mocker.removeAll()
    }

    // MARK: Client - getStatusCode

    private func testGetStatusCode(statusCode: Int) async {
        let testExpectation = XCTestExpectation(description: "Status code: \(statusCode)")
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
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
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
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
        case .clientError(let body, let statusCode, let parseResult):
            XCTAssertEqual(body!.message, "generic error")
            XCTAssertEqual(statusCode, mockStatusCode)
            XCTAssertEqual(parseResult, .success)
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
        case .serverError(let body, let statusCode, let parseResult):
            XCTAssertEqual(body!.message, "generic error")
            XCTAssertEqual(statusCode, mockStatusCode)
            XCTAssertEqual(parseResult, .success)
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
        case .genericError(let body, let statusCode, let parseResult):
            XCTAssertEqual(body!.message, "generic error")
            XCTAssertEqual(statusCode, mockStatusCode)
            XCTAssertEqual(parseResult, .success)
            testExpectation.fulfill()
        default:
            XCTFail("testExpectationFifthAPICall expectarion not satisied!")
        }
    }

    // MARK: buildRequest

    // #1: [urlPathComponent: nil, urlQueryParameters nil, httpBody nil, httpHeaderFields not set]
    func testBuildRequestWithSettingsUrlPathComponentNilAndUrlQueryParametersNilAndHttpBodyNilAndHttpHeaderFieldsNotSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: nil,
                                          urlQueryParameters: nil,
                                          httpBody: nil,
                                          httpMethod: .get)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/")
        XCTAssertEqual(request.httpBody, nil)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
    }

    // #2: [urlPathComponent: !nil, urlQueryParameters nil, httpBody nil, httpHeaderFields not set]
    func testBuildRequestWithSettingsUrlPathComponentNotNilAndUrlQueryParametersNilAndHttpBodyNilAndHttpHeaderFieldsNotSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: "test",
                                          urlQueryParameters: nil,
                                          httpBody: nil,
                                          httpMethod: .get)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/test")
        XCTAssertEqual(request.httpBody, nil)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
    }

    // #3: [urlPathComponent: !nil, urlQueryParameters !nil, httpBody nil, httpHeaderFields not set]
    func testBuildRequestWithSettingsUrlPathComponentNotNilAndUrlQueryParametersNotNilAndHttpBodyNilAndHttpHeaderFieldsNotSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let urlQueryParameters = ["q1":"v1"]
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: "test",
                                          urlQueryParameters: urlQueryParameters,
                                          httpBody: nil,
                                          httpMethod: .get)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/test?q1=v1")
        XCTAssertEqual(request.httpBody, nil)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
    }

    // #4: [urlPathComponent: !nil, urlQueryParameters nil, httpBody !nil, httpHeaderFields not set]
    func testBuildRequestWithSettingsUrlPathComponentNotNilAndUrlQueryParametersNilAndHttpBodyNotNilAndHttpHeaderFieldsNotSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let httpBody: Data = "body".data(using: .utf8)!
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: "test",
                                          urlQueryParameters: nil,
                                          httpBody: httpBody,
                                          httpMethod: .get)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/test")
        XCTAssertEqual(request.httpBody, httpBody)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
    }

    // #5: [urlPathComponent: nil, urlQueryParameters !nil, httpBody nil, httpHeaderFields not set]
    func testBuildRequestWithSettingsUrlPathComponentNilAndUrlQueryParametersNotNilAndHttpBodyNilAndHttpHeaderFieldsNotSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let urlQueryParameters = ["q1":"v1"]
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: nil,
                                          urlQueryParameters: urlQueryParameters,
                                          httpBody: nil,
                                          httpMethod: .get)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/?q1=v1")
        XCTAssertEqual(request.httpBody, nil)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
    }

    // #6: [urlPathComponent: nil, urlQueryParameters nil, httpBody !nil, httpHeaderFields not set]
    func testBuildRequestWithSettingsUrlPathComponentNilAndUrlQueryParametersNilAndHttpBodyNotNilAndHttpHeaderFieldsNotSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let httpBody: Data = "body".data(using: .utf8)!
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: nil,
                                          urlQueryParameters: nil,
                                          httpBody: httpBody,
                                          httpMethod: .get)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/")
        XCTAssertEqual(request.httpBody, httpBody)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
    }

    // #7: [urlPathComponent: nil, urlQueryParameters !nil, httpBody !nil, httpHeaderFields not set]
    func testBuildRequestWithSettingsUrlPathComponentNilAndUrlQueryParametersNotNilAndHttpBodyNotNilAndHttpHeaderFieldsNotSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let urlQueryParameters = ["q1":"v1"]
        let httpBody: Data = "body".data(using: .utf8)!
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: nil,
                                          urlQueryParameters: urlQueryParameters,
                                          httpBody: httpBody,
                                          httpMethod: .get)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/?q1=v1")
        XCTAssertEqual(request.httpBody, httpBody)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
    }

    // #8: [urlPathComponent: !nil, urlQueryParameters !nil, httpBody !nil, httpHeaderFields not set]
    func testBuildRequestWithSettingsUrlPathComponentNotNilAndUrlQueryParametersNotNilAndHttpBodyNotNilAndHttpHeaderFieldsNotSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let httpBody: Data = "body".data(using: .utf8)!
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: "test",
                                          urlQueryParameters: ["q1":"v1"],
                                          httpBody: httpBody,
                                          httpMethod: .get)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/test?q1=v1")
        XCTAssertEqual(request.httpBody, httpBody)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
    }

    // #9: [urlPathComponent: nil, urlQueryParameters nil, httpBody nil, httpHeaderFields set]
    func testBuildRequestWithSettingsUrlPathComponentNilAndUrlQueryParametersNilAndHttpBodyNilAndHttpHeaderFieldsSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let httpHeaderFields = ["Authorization": "Bearer \(UUID().uuidString)"]
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: nil,
                                          urlQueryParameters: nil,
                                          httpBody: nil,
                                          httpMethod: .get,
                                          httpHeaderFields: httpHeaderFields)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/")
        XCTAssertEqual(request.httpBody, nil)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, httpHeaderFields)
    }

    // #10: [urlPathComponent: !nil, urlQueryParameters nil, httpBody nil, httpHeaderFields set]
    func testBuildRequestWithSettingsUrlPathComponentNotNilAndUrlQueryParametersNilAndHttpBodyNilAndHttpHeaderFieldsNot() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let httpHeaderFields = ["Authorization": "Bearer \(UUID().uuidString)"]
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: "test",
                                          urlQueryParameters: nil,
                                          httpBody: nil,
                                          httpMethod: .get,
                                          httpHeaderFields: httpHeaderFields)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/test")
        XCTAssertEqual(request.httpBody, nil)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, httpHeaderFields)
    }

    // #11: [urlPathComponent: !nil, urlQueryParameters !nil, httpBody nil, httpHeaderFields set]
    func testBuildRequestWithSettingsUrlPathComponentNotNilAndUrlQueryParametersNotNilAndHttpBodyNilAndHttpHeaderFieldsSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let urlQueryParameters = ["q1":"v1"]
        let httpHeaderFields = ["Authorization": "Bearer \(UUID().uuidString)"]
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: "test",
                                          urlQueryParameters: urlQueryParameters,
                                          httpBody: nil,
                                          httpMethod: .get,
                                          httpHeaderFields: httpHeaderFields)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/test?q1=v1")
        XCTAssertEqual(request.httpBody, nil)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, httpHeaderFields)
    }

    // #12: [urlPathComponent: !nil, urlQueryParameters nil, httpBody !nil, httpHeaderFields set]
    func testBuildRequestWithSettingsUrlPathComponentNotNilAndUrlQueryParametersNilAndHttpBodyNotNilAndHttpHeaderFieldsSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let httpBody: Data = "body".data(using: .utf8)!
        let httpHeaderFields = ["Authorization": "Bearer \(UUID().uuidString)"]
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: "test",
                                          urlQueryParameters: nil,
                                          httpBody: httpBody,
                                          httpMethod: .get,
                                          httpHeaderFields: httpHeaderFields)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/test")
        XCTAssertEqual(request.httpBody, httpBody)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, httpHeaderFields)
    }

    // #13: [urlPathComponent: nil, urlQueryParameters !nil, httpBody nil, httpHeaderFields set]
    func testBuildRequestWithSettingsUrlPathComponentNilAndUrlQueryParametersNotNilAndHttpBodyNilAndHttpHeaderFieldsSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let urlQueryParameters = ["q1":"v1"]
        let httpHeaderFields = ["Authorization": "Bearer \(UUID().uuidString)"]
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: nil,
                                          urlQueryParameters: urlQueryParameters,
                                          httpBody: nil,
                                          httpMethod: .get,
                                          httpHeaderFields: httpHeaderFields)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/?q1=v1")
        XCTAssertEqual(request.httpBody, nil)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, httpHeaderFields)
    }

    // #14: [urlPathComponent: nil, urlQueryParameters nil, httpBody !nil, httpHeaderFields set]
    func testBuildRequestWithSettingsUrlPathComponentNilAndUrlQueryParametersNilAndHttpBodyNotNilAndHttpHeaderFieldsSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let httpBody: Data = "body".data(using: .utf8)!
        let httpHeaderFields = ["Authorization": "Bearer \(UUID().uuidString)"]
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: nil,
                                          urlQueryParameters: nil,
                                          httpBody: httpBody,
                                          httpMethod: .get,
                                          httpHeaderFields: httpHeaderFields)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/")
        XCTAssertEqual(request.httpBody, httpBody)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, httpHeaderFields)
    }

    // #15: [urlPathComponent: nil, urlQueryParameters !nil, httpBody !nil, httpHeaderFields set]
    func testBuildRequestWithSettingsUrlPathComponentNilAndUrlQueryParametersNotNilAndHttpBodyNotNilAndHttpHeaderFieldsSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let urlQueryParameters = ["q1":"v1"]
        let httpBody: Data = "body".data(using: .utf8)!
        let httpHeaderFields = ["Authorization": "Bearer \(UUID().uuidString)"]
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: nil,
                                          urlQueryParameters: urlQueryParameters,
                                          httpBody: httpBody,
                                          httpMethod: .get,
                                          httpHeaderFields: httpHeaderFields)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/?q1=v1")
        XCTAssertEqual(request.httpBody, httpBody)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, httpHeaderFields)
    }

    // #16: [urlPathComponent: !nil, urlQueryParameters !nil, httpBody !nil, httpHeaderFields set]
    func testBuildRequestWithSettingsUrlPathComponentNotNilAndUrlQueryParametersNotNilAndHttpBodyNotNilAndHttpHeaderFieldsSet() {
        let serviceURL: URL = URL(string: "www.vargroup.it/digital-cloud/")!
        let httpBody: Data = "body".data(using: .utf8)!
        let httpHeaderFields = ["Authorization": "Bearer \(UUID().uuidString)"]
        let settings = APIRequestSettings(url: serviceURL,
                                          urlPathComponent: "test",
                                          urlQueryParameters: ["q1":"v1"],
                                          httpBody: httpBody,
                                          httpMethod: .get,
                                          httpHeaderFields: httpHeaderFields)

        let request = client.buildRequest(settings)
        XCTAssertEqual(request.url!.absoluteString, "www.vargroup.it/digital-cloud/test?q1=v1")
        XCTAssertEqual(request.httpBody, httpBody)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, httpHeaderFields)
    }

    // MARK: buildAuthenticatedRequest
    func testBuildAuthenticatedRequestWithValidAccessKey() {
        var request = URLRequest(url: URL(string: "www.vargroup.it/digital-cloud/")!)
        let accessToken = UUID().uuidString
        client.buildAuthenticatedRequest(&request, authScheme: .Bearer, accessToken: accessToken)
        XCTAssertEqual(request.allHTTPHeaderFields, ["Authorization": "Bearer \(accessToken)"])
    }

    func testBuildAuthenticatedRequestWithNilAccessKey() {
        var request = URLRequest(url: URL(string: "www.vargroup.it/digital-cloud/")!)
        client.buildAuthenticatedRequest(&request, authScheme: .Bearer, accessToken: nil)
        XCTAssertEqual(request.allHTTPHeaderFields, nil)
    }

    // MARK: handleResponse

    func testHandleResponseWithValidDataFormat1() {
        let mockData = mockedDataSourceData(fileName: "response_json_valid_data_1")
        do {
            let model: TestModel = try client.handleResponse(from: mockData)
            XCTAssertEqual(model.id, 1234)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            XCTAssertEqual(dateFormatter.string(from: model.dateFirstAvailability), "2012-02-28")
            XCTAssertEqual(model.baseUrl, "www.vargroup.it/digital-cloud/")
        } catch {
            XCTFail("Failed to parse the model with error: \(error)")
        }
    }

    func testHandleResponseWithValidDataFormat2() {
        let mockData = mockedDataSourceData(fileName: "response_json_valid_data_2")
        do {
            let model: TestModel = try client.handleResponse(from: mockData)
            XCTAssertEqual(model.id, 5678)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            XCTAssertEqual(dateFormatter.string(from: model.dateFirstAvailability), "2012-02-28")
            XCTAssertEqual(model.baseUrl, "www.vargroup.it/digital-cloud/")
        } catch {
            XCTFail("Failed to parse the model with error: \(error)")
        }
    }

    func testHandleResponseWithNoConformDataFormat() {
        let mockData = mockedDataSourceData(fileName: "response_json_invalid_data")
        do {
            let _: TestModel = try client.handleResponse(from: mockData)
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
        }
    }

    func testHandleResponseWithExtraFieldInResponseBody() {
        let mockData = mockedDataSourceData(fileName: "response_json_extra_field")
        do {
            let model: TestModel = try client.handleResponse(from: mockData)
            XCTAssertEqual(model.id, 4357)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            XCTAssertEqual(dateFormatter.string(from: model.dateFirstAvailability), "2012-02-28")
            XCTAssertEqual(model.baseUrl, "www.vargroup.it/digital-cloud/")
        } catch {
            XCTFail("Failed to parse the model with error: \(error)")
        }
    }

    func testHandleResponseWithMissingFieldInResponseBody() {
        let mockData = mockedDataSourceData(fileName: "response_json_missing_field")
        do {
            let _: TestModel = try client.handleResponse(from: mockData)
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is DecodingError, "Unexpected error type: \(type(of: error))")
        }
    }

    func testHandleResponseWithMissingValueInResponseBody() {
        let mockData = mockedDataSourceData(fileName: "response_json_missing_value")
        do {
            let _: TestModel = try client.handleResponse(from: mockData)
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is DecodingError, "Unexpected error type: \(type(of: error))")
        }
    }

    func testHandleResponseWithTypeMismatchFieldInResponseBody() {
        let mockData = mockedDataSourceData(fileName: "response_json_type_mismatch_field")
        do {
            let _: TestModel = try client.handleResponse(from: mockData)
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is DecodingError, "Unexpected error type: \(type(of: error))")
        }
    }


    func testHandleResponseWithEmptyResponseBody() {
        let mockData = mockedDataSourceData(fileName: "response_json_empty")
        do {
            let _: EmptyContent = try client.handleResponse(from: mockData)
        } catch {
            XCTFail("Failed to parse the model with error: \(error)")
        }
    }

    // MARK: - Test run

    func testRunSuccess() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "response_json_valid_data_1")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 200,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let model: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTAssertEqual(model.id, 1234)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            XCTAssertEqual(dateFormatter.string(from: model.dateFirstAvailability), "2012-02-28")
            XCTAssertEqual(model.baseUrl, "www.vargroup.it/digital-cloud/")
        } catch {
            XCTFail("Failed to run the api with error: \(error.localizedDescription)")
        }
    }

    func testRunEmptyBodySuccess() async {
        let mockResponseData: Data = Data()
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 204,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let model: EmptyContent =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTAssertEqual(model, EmptyContent())
        } catch {
            XCTFail("Failed to run the api with error: \(error.localizedDescription)")
        }
    }

    func testRunParsingFailTypeMismatch() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "response_json_type_mismatch_field")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 200,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            let networkError = error as! NetworkError<TestError>
            switch networkError {
            case .decodeError(_, let statusCode):
                XCTAssertEqual(statusCode, 200)
            default:
                XCTFail("Wrong error type")
            }
            XCTAssertTrue(error.localizedDescription.starts(with: "Decode Error:"))
        }
    }

    func testRunParsingFailMissingField() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "response_json_missing_field")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 200,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            let networkError = error as! NetworkError<TestError>
            switch networkError {
            case .decodeError(_, let statusCode):
                XCTAssertEqual(statusCode, 200)
            default:
                XCTFail("Wrong error type")
            }
            XCTAssertTrue(error.localizedDescription.starts(with: "Decode Error:"))
        }
    }

    func testRunParsingFailMissingValue() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "response_json_missing_value")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 200,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            let networkError = error as! NetworkError<TestError>
            switch networkError {
            case .decodeError(_, let statusCode):
                XCTAssertEqual(statusCode, 200)
            default:
                XCTFail("Wrong error type")
            }
        }
    }

    func testRunParsingFailEmptyBody() async {
        let mockResponseData: Data = Data()
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 200,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            XCTAssertEqual(error.localizedDescription, "Empty body Error: Expected to find TestModel but found no content body instead, with statusCode 200")
        }
    }

    func testRunFailClientError() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "error_model")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 400,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            let networkError = error as! NetworkError<TestError>
            switch networkError {
            case .clientError(let body, let statusCode, let parseResult):
                XCTAssertEqual(body?.message, "generic error")
                XCTAssertEqual(statusCode, 400)
                XCTAssertEqual(parseResult, .success)
            default:
                XCTFail("Wrong error type")
            }
            XCTAssertEqual(error.localizedDescription, "Client Error: 400 Optional(CommonNetworkingTests.TestError(message: \"generic error\"))")
        }
    }

    func testRunFailClientDecodeError() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "response_json_empty")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 400,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            let networkError = error as! NetworkError<TestError>
            switch networkError {
            case .clientError(let body, let statusCode, let parseResult):
                XCTAssertEqual(body, nil)
                XCTAssertEqual(statusCode, 400)
                XCTAssertEqual(parseResult, .decodeError(message: "Missing field: message"))
            default:
                XCTFail("Wrong error type")
            }
            XCTAssertEqual(error.localizedDescription, "Client Error: 400 nil")
        }
    }

    func testRunFailServerError() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "error_model")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 500,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            let networkError = error as! NetworkError<TestError>
            switch networkError {
            case .serverError(let body, let statusCode, let parseResult):
                XCTAssertEqual(body?.message, "generic error")
                XCTAssertEqual(statusCode, 500)
                XCTAssertEqual(parseResult, .success)
            default:
                XCTFail("Wrong error type")
            }
            XCTAssertEqual(error.localizedDescription, "Server Error: 500 Optional(CommonNetworkingTests.TestError(message: \"generic error\"))")
        }
    }

    func testRunFailServerDecodeError() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "response_json_empty")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 500,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            let networkError = error as! NetworkError<TestError>
            switch networkError {
            case .serverError(let body, let statusCode, let parseResult):
                XCTAssertEqual(body, nil)
                XCTAssertEqual(statusCode, 500)
                XCTAssertEqual(parseResult, .decodeError(message: "Missing field: message"))
            default:
                XCTFail("Wrong error type")
            }
            XCTAssertEqual(error.localizedDescription, "Server Error: 500 nil")
        }
    }

    func testRunFailUnauthorizedError() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "unauthorized_error_model")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 401,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            let networkError = error as! NetworkError<TestError>
            switch networkError {
            case .clientError(let body, let statusCode, let parseResult):
                XCTAssertEqual(body?.message, "unauthorized")
                XCTAssertEqual(statusCode, 401)
                XCTAssertEqual(parseResult, .success)
            default:
                XCTFail("Wrong error type")
            }
            XCTAssertEqual(error.localizedDescription, "Client Error: 401 Optional(CommonNetworkingTests.TestError(message: \"unauthorized\"))")
        }
    }

    func testRunFailUnauthorizedDecodeError() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "response_json_empty")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 401,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            let networkError = error as! NetworkError<TestError>
            switch networkError {
            case .clientError(let body, let statusCode, let parseResult):
                XCTAssertEqual(body?.message, nil)
                XCTAssertEqual(statusCode, 401)
                XCTAssertEqual(parseResult, .decodeError(message: "Missing field: message"))
            default:
                XCTFail("Wrong error type")
            }
            XCTAssertEqual(error.localizedDescription, "Client Error: 401 nil")
        }
    }

    func testRunFailGenericError() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "error_model")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 800,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            let networkError = error as! NetworkError<TestError>
            switch networkError {
            case .genericError(let body, let statusCode, let parseResult):
                XCTAssertEqual(body?.message, "generic error")
                XCTAssertEqual(statusCode, 800)
                XCTAssertEqual(parseResult, .success)
            default:
                XCTFail("Wrong error type")
            }
            XCTAssertEqual(error.localizedDescription, "Generic Error: 800 Optional(CommonNetworkingTests.TestError(message: \"generic error\"))")
        }
    }

    func testRunFailGenericDecodeError() async {
        let mockResponseData: Data = mockedDataSourceData(fileName: "response_json_empty")
        XCTAssertNotNil(mockResponseData)
        let mockServiceURL = URL(string: "www.vargroup.it/digital-cloud/")!

        let mock: Mock = Mock(
            url: mockServiceURL,
            ignoreQuery: true,
            dataType: .json,
            statusCode: 800,
            data: [.get: mockResponseData])

        mock.register()
        do {
            let _: TestModel =  try await client.run(.init(url: URL(string: "www.vargroup.it/digital-cloud/")!, urlPathComponent: nil, httpMethod: .get))
            XCTFail("Failed the data is invalid and the the handle response had to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError<TestError>, "Unexpected error type: \(type(of: error))")
            let networkError = error as! NetworkError<TestError>
            switch networkError {
            case .genericError(let body, let statusCode, let parseResult):
                XCTAssertEqual(body?.message, nil)
                XCTAssertEqual(statusCode, 800)
                XCTAssertEqual(parseResult, .decodeError(message: "Missing field: message"))
            default:
                XCTFail("Wrong error type")
            }
            XCTAssertEqual(error.localizedDescription, "Generic Error: 800 nil")
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

    private func mockedDataSourceData(fileName: String) -> Data {
        let url = Bundle.module.url(forResource: fileName,
                                    withExtension: "json",
                                    subdirectory: "Mocks")!
        return try! Data(contentsOf: url)
    }
}
