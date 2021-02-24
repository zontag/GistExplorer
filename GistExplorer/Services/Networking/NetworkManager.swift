import Foundation
import RxSwift
import RxCocoa

enum NetworkingMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol Target {
    var baseURL: String { get }
    var path: String { get }
    var method: NetworkingMethod { get }
    var queryParams: [String: String?] { get }
}

protocol TargetRequestable {
    func request<ResultType>(_ target: Target) ->  Single<ResultType> where ResultType: Decodable
}

extension URLSession: TargetRequestable {

    private func makeRequest(_ target: Target) -> Observable<URLRequest> {
        var components = URLComponents()
        components.scheme = "https"
        components.host = target.baseURL
        components.queryItems = target.queryParams.compactMap { (param) -> URLQueryItem? in
            guard let value = param.value, !value.isEmpty else { return nil }
            return URLQueryItem(name: param.key, value: value)
        }
        components.path = target.path
        guard let url = components.url
        else { return .error(URLError(.badURL)) }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "accept")
        request.httpMethod = target.method.rawValue
        return .just(request)
    }

    func request<ResultType>(_ target: Target) -> Single<ResultType> where ResultType: Decodable {
        makeRequest(target)
            .flatMap(URLSession.shared.rx.data)
            .decode(type: ResultType.self, decoder: JSONDecoder())
            .asSingle()
    }
}
