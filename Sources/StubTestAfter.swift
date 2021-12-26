import Foundation

public protocol RequestConvertible {
    var urlRequest: URLRequest { get }
    var stub: Stub? { get }
}

public enum Stub {
    case response(Response)
    
    public struct Response {
        public let response: URLResponse
        public let result: Result<Data, Error>

        public init(response: URLResponse, result: Result<Data, Error>) {
            self.response = response
            self.result = result
        }
    }
    
    public enum Error: Swift.Error {
        case emptyStubResponse
        case statusCode(Int)
    }
}

public enum Subscription {
    public enum Error: Swift.Error {
        case unExpected(response: HTTPURLResponse)
    }
    
    public struct Request: RequestConvertible {
        public let urlRequest: URLRequest
        public var stub: Stub?

        public init(urlRequest: URLRequest, stub: Stub?) {
            self.urlRequest = urlRequest
            self.stub = stub
        }
    }
    
    public struct Response: Decodable {
        public let subscribed: Bool
        public let subscriptionCount: Int
    }
    
    public struct Worker {
        public static func update(request: Request,
                                  completion: @escaping ((Result<Response, Swift.Error>) -> Void)) {
            
            let dataTask = URLSession(configuration: .default)
                .dataTask(request: request, completionHanlder: { data, urlResponse, error in
                    
                    if let error = error {
                        completion(.failure(error))
                    }
                    guard
                        let data = data,
                        let urlResponse = urlResponse as? HTTPURLResponse else {
                            return
                        }
                    switch urlResponse.statusCode {
                    case 200:
                        do {
                            let response = try JSONDecoder().decode(Response.self,
                                                                    from: data)
                            completion(.success(response))
                        } catch {
                            completion(.failure(error))
                        }
                    default:
                        completion(.failure(Error.unExpected(response: urlResponse)))
                    }
                })
            dataTask?.resume()
        }
    }
}

extension URLSession {
    public typealias CompletionHandler = (Data?, URLResponse?, Swift.Error?) -> Void
    
    public func dataTask(request: RequestConvertible,
                         completionHanlder: @escaping CompletionHandler) -> URLSessionDataTask? {
        
        guard let stub = request.stub else {
            return dataTask(with: request.urlRequest, completionHandler: completionHanlder)
        }
        
        switch stub {
        case .response(let stubResponse):
            switch stubResponse.result {
            case .success(let data):
                completionHanlder(data, stubResponse.response, nil)
            case .failure(let error):
                completionHanlder(nil, stubResponse.response, error)
            }
        }
        return nil
    }
}
