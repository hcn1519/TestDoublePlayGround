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
                assert(response.subscribed == true)
                assert(response.subscriptionCount == 27038)
                print("\(#function) success")
            case .failure:
                assertionFailure()
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
            case .success:
                assertionFailure()
            case .failure(let error):
                if let stubError = error as? Stub.Error {
                    switch stubError {
                    case .statusCode(let code):
                        assert(code == 404)
                        print("\(#function) success")
                    default:
                        assertionFailure()
                    }
                }
            }
        })
    }
}

enum SpyTest {

    static func testRealDOCFlight() {
        let flights: [Flight] = [Flight(number: 1),
                                 Flight(number: 2),
                                 Flight(number: 3),
                                 Flight(number: 4)]

        var airPort = Airport(flights: flights, controlTower: ControlTower())

        // exercise
        airPort.removeFlight(number: 3)
        airPort.addFlights([.init(number: 5)])

        // verify
        assert(airPort.flights.count == 4)
        assert(airPort.hasFlight(number: 3) == false)
        assert(airPort.hasFlight(number: 5) == true)

        let removeNotification = airPort.controlTower.notifications.first
        assert(removeNotification?.actionCode == "remove(number:)")
        
        print("\(#function) success")
    }

    static func testSpyFlight() {
        let flights: [Flight] = [Flight(number: 1),
                                 Flight(number: 2),
                                 Flight(number: 3),
                                 Flight(number: 4)]

        let controlTowerSpy = ControlTowerSpy()
        var airPort = Airport(flights: flights, controlTower: controlTowerSpy)

        // exercise
        airPort.removeFlight(number: 3)
        airPort.addFlights([.init(number: 5)])

        // verify
        assert(airPort.flights.count == 4)
        assert(airPort.hasFlight(number: 3) == false)
        assert(airPort.hasFlight(number: 5) == true)

        let removeNotification = airPort.controlTower.notifications.first
        assert(removeNotification?.actionCode == "remove(number:)")

        // indirect output
        let spy = airPort.controlTower as? ControlTowerSpy
        assert(spy?.numberOfReports == 2)
        print("\(#function) success")
    }

    static func testSpyJsonViewerShowJson() {
        // setup
        let interactor = JsonViewer.Interactor()
        let presenterSpy = JsonViewer.PresenterSpy()
        interactor.presenter = presenterSpy

        // exercise
        let sampleData = """
        {
            "spy": true
        }
        """.data(using: .utf8)!

        interactor.showJson(request: .init(data: sampleData))

        // Verify indirect output
        assert(presenterSpy.presentJsonIsCalled)
        assert(presenterSpy.jsonModel?.spy ?? false == true)
        print("\(#function) success")
    }
}

StubTest.testSuccess()
StubTest.testFailure()
SpyTest.testSpyJsonViewerShowJson()
SpyTest.testRealDOCFlight()
SpyTest.testSpyFlight()
