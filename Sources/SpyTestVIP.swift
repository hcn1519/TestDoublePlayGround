import Foundation

public enum JsonViewer {
    public struct Request {
        let data: Data

        public init(data: Data) {
            self.data = data
        }
    }

    public struct Response {
        let jsonString: String
    }

    public struct ViewModel {
        let jsonString: String
    }
}

public protocol JsonViewerBusinessLogic {
    func showJson(request: JsonViewer.Request)
}

extension JsonViewer {
    public class Interactor: JsonViewerBusinessLogic {
        // Depended-on-Component(Spy)
        public var presenter: JsonViewerPresentationLogic?

        public init() {}

        // System Under Test
        public func showJson(request: Request) {

            guard let jsonString = String(data: request.data, encoding: .utf8) else {
                return
            }
            presenter?.presentJson(response: .init(jsonString: jsonString))
        }
    }
}

public protocol JsonViewerPresentationLogic {
    func presentJson(response: JsonViewer.Response)
}

extension JsonViewer {
    public class Presenter: JsonViewerPresentationLogic {

        var viewer: JsonViewerDisplayLogic?

        public init() {}

        public func presentJson(response: Response) {
            viewer?.displayJson(viewModel: ViewModel(jsonString: response.jsonString))
        }
    }
}

public protocol JsonViewerDisplayLogic {
    func displayJson(viewModel: JsonViewer.ViewModel)
}

extension JsonViewer {
    public class Displayer: JsonViewerDisplayLogic {
        public func displayJson(viewModel: ViewModel) {
            print(viewModel.jsonString)
        }
    }

    public class PresenterSpy: JsonViewerPresentationLogic {

        public struct ResultModel: Decodable {
            public let spy: Bool
        }

        public var passedJsonString: String?
        public var presentJsonIsCalled: Bool = false
        public var jsonModel: ResultModel?

        public init() {}

        public func presentJson(response: Response) {
            let data = response.jsonString.data(using: .utf8) ?? Data()

            self.jsonModel = try? JSONDecoder().decode(ResultModel.self, from: data)
            self.passedJsonString = response.jsonString
            self.presentJsonIsCalled = true
        }
    }
}

