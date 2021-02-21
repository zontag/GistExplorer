import Foundation

enum GithubAPI {
    case gistList(limit: Int, page: Int)
}

extension GithubAPI: Target {

    var baseURL: String { "api.github.com" }

    var path: String {
        switch self {
        case .gistList:
            return "/gists/public"
        }
    }

    var method: NetworkingMethod {
        switch self {
        case .gistList:
            return .get
        }
    }

    var queryParams: [String: String?] {
        switch self {
        case .gistList(let limit, let page):
            return ["per_page": String(limit), "page": String(page)]
        }
    }
}
