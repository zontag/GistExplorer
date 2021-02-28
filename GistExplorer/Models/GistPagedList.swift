import Foundation
import RxSwift
import RxRelay

protocol GistPagedListModel {
    var loadRelay: PublishRelay<Void> { get }
    var gistListInfallible: Infallible<[Gist]> { get }
    var errorInfallible: Infallible<String> { get }
}

final class GistPagedList: GistPagedListModel {

    private let disposeBag = DisposeBag()
    private let githubNetwork: GithubNetworkDispatchable
    private var limit: Int
    private var page = 0

    let loadRelay = PublishRelay<Void>()
    var gistListInfallible: Infallible<[Gist]>
    var errorInfallible: Infallible<String>

    private let gistListRelay = PublishRelay<[Gist]>()
    private let errorRelay = PublishRelay<String>()
    private var gistList: [Gist] = []

    init(limit: Int, githubNetwork: GithubNetworkDispatchable) {
        self.githubNetwork = githubNetwork
        self.limit = limit
        gistListInfallible = gistListRelay.asInfallible(onErrorJustReturn: [])
        errorInfallible = errorRelay.asInfallible(onErrorJustReturn: "")
        bind()
    }

    private func bind() {
        loadRelay
            .withUnretained(self)
            .flatMapLatest({ owner, _ in
                owner.githubNetwork.gistList(limit: owner.limit, page: owner.page)
            })
            .map { list in
                list.map(Map.mapResponseToGist())
            }
            .scan([Gist](), accumulator: +)
            .asInfallible(onErrorRecover: { [weak self] (error) -> Infallible<[Gist]> in
                self?.errorRelay.accept(error.localizedDescription)
                self?.page = 0
                return Infallible.just([])
            })
            .withUnretained(self)
            .subscribe(onNext: { (owner, items) in
                if items.isEmpty { return }
                owner.page += 1
                owner.gistListRelay.accept(items)
            })
            .disposed(by: disposeBag)
    }
}
