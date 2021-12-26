import Foundation

/*
protocol RequestConvertible {
    var urlRequest: URLRequest { get }
}

enum Subscription {
    enum SubscriptionError: Swift.Error {
        case unExpected(response: HTTPURLResponse)
    }

    struct Request: RequestConvertible {
        let urlRequest: URLRequest
    }

    struct Response: Decodable {
        let subscribed: Int
        let subscriptionCount: Bool
    }

    struct Worker {
        static func update(request: RequestConvertible,
                           completion: @escaping ((Result<Response, Error>) -> Void)) {

            let dataTask = URLSession(configuration: .default)
                .dataTask(with: request.urlRequest, completionHandler: { data, urlResponse, error in

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
                        completion(.failure(SubscriptionError.unExpected(response: urlResponse)))
                    }
                })
            dataTask.resume()
        }
    }
}

// Usage
let urlRequest = URLRequest(url: URL(string: "https://hcn1519.github.io")!)
Subscription.Worker.update(request: .init(urlRequest: urlRequest), completion: { result in
    // do something
    print(result)
})
*/
