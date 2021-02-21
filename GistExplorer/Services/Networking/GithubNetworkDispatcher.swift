import Foundation
import RxSwift

protocol GithubNetworkDispatchable {
    func gistList(limit: Int, page: Int) -> Single<GistListResponse>
}

final class GithubNetworkDispatcher: GithubNetworkDispatchable {

    var networkDispatcher: TargetRequestable

    init(networkDispatcher: TargetRequestable) {
        self.networkDispatcher = networkDispatcher
    }

    func gistList(limit: Int, page: Int) -> Single<GistListResponse> {
        networkDispatcher.request(GithubAPI.gistList(limit: limit, page: page))
    }
}
