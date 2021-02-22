import Foundation
import RxSwift
import RxRelay

protocol GistPagedListModel {
    var loadRelay: PublishRelay<Void> { get }
    var gistListRelay: BehaviorRelay<[Gist]> { get }
    var errorRelay: PublishRelay<String> { get }
}

final class GistPagedList: GistPagedListModel {

    private let disposeBag = DisposeBag()
    private let injector: Injectable
    private let githubNetwork: GithubNetworkDispatchable
    private var limit: Int
    private var page = 0

    let loadRelay = PublishRelay<Void>()
    let gistListRelay = BehaviorRelay<[Gist]>(value: [])
    let errorRelay = PublishRelay<String>()

    init(limit: Int, injector: Injectable) {
        self.githubNetwork = injector()
        self.injector = injector
        self.limit = limit
        bind()
    }

    private func bind() {
        loadRelay
            .flatMapLatest({ self.githubNetwork.gistList(limit: self.limit, page: self.page) })
            .map { list in list.map(Map.mapResponseToGist(injector: self.injector)) }
            .asInfallible(onErrorRecover: { (error) -> Infallible<[Gist]> in
                self.errorRelay.accept(error.localizedDescription)
                return Infallible.just(self.gistListRelay.value)
            })
            .subscribe(onNext: { (items) in
                if items.isEmpty { return }
                self.page += 1
                var gistList = self.gistListRelay.value
                gistList.append(contentsOf: items)
                self.gistListRelay.accept(gistList)
            })
            .disposed(by: disposeBag)
    }
}
