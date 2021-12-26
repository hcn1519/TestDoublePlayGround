import UIKit
import XCTest

enum StubTest {
    static func testSuccess() {
        let urlRequest = URLRequest(url: URL(string: "https://hcn1519.github.io")!)

        let successData = """
        {
            "subscribed": true,
            "subscriptionCount": 27038
        }
        """.data(using: .utf8)!

        let successURLResponse = HTTPURLResponse(url: urlRequest.url!,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: [:])!
        let successResponse = Stub.Response(response: successURLResponse,
                                            result: .success(successData))

        let successStub = Stub.response(successResponse)
        let successRequest = Subscription.Request(urlRequest: urlRequest,
                                                  stub: successStub)

        Subscription.Worker.update(request: successRequest, completion: { result in
            switch result {
            case .success(let response):
                XCTAssert(response.subscribed == true)
                XCTAssert(response.subscriptionCount == 27038)
                print("\(#function) success")
            case .failure(let error):
                XCTAssert(false, "Result should succeed \(error.localizedDescription)")
            }
        })
    }

    static func testFailure() {
        let urlRequest = URLRequest(url: URL(string: "https://hcn1519.github.io")!)

        let failureResponse = HTTPURLResponse(url: urlRequest.url!,
                                              statusCode: 404,
                                              httpVersion: nil,
                                              headerFields: [:])!

        let response = Stub.Response(response: failureResponse,
                                     result: .failure(.statusCode(404)))
        let failureStub = Stub.response(response)
        let request = Subscription.Request(urlRequest: urlRequest,
                                           stub: failureStub)

        Subscription.Worker.update(request: request, completion: { result in
            switch result {
            case .success(let response):
                XCTAssert(false, "Result should fail \(response)")
            case .failure(let error):
                if let stubError = error as? Stub.Error {
                    switch stubError {
                    case .statusCode(let code):
                        XCTAssert(code == 404)
                        print("\(#function) success")
                    default:
                        XCTAssert(false, "UnExpected Error \(stubError)")
                    }
                }
            }
        })
    }
}

StubTest.testSuccess()
StubTest.testFailure()
