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
    private let injector: Injectable
    private let githubNetwork: GithubNetworkDispatchable
    private var limit: Int
    private var page = 0

    let loadRelay = PublishRelay<Void>()
    var gistListInfallible: Infallible<[Gist]>
    var errorInfallible: Infallible<String>

    private let gistListRelay = PublishRelay<[Gist]>()
    private let errorRelay = PublishRelay<String>()
    private var gistList: [Gist] = []

    init(limit: Int, injector: Injectable) {
        self.githubNetwork = injector()
        self.injector = injector
        self.limit = limit
        gistListInfallible = gistListRelay.asInfallible(onErrorJustReturn: [])
        errorInfallible = errorRelay.asInfallible(onErrorJustReturn: "")
        bind()
    }

    private func bind() {
        loadRelay
            .flatMapLatest({
                self.githubNetwork.gistList(limit: self.limit, page: self.page)
            })
            .map { list in
                list.map(Map.mapResponseToGist())
            }
            .scan([Gist](), accumulator: +)
            .asInfallible(onErrorRecover: { (error) -> Infallible<[Gist]> in
                self.errorRelay.accept(error.localizedDescription)
                self.page = 0
                return Infallible.just([])
            })
            .subscribe(onNext: { (items) in
                if items.isEmpty { return }
                self.page += 1
                self.gistListRelay.accept(items)
            })
            .disposed(by: disposeBag)
    }
}
