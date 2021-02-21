import Foundation
import RxSwift
import RxCocoa

final class GistListViewModel: GistListViewModelIO {

    private let disposeBag = DisposeBag()
    private let gistListManager: GistPagedListModel
    private let favoritesGistManager: FavoritesGistModel

    var input: GistListViewModelInput
    var output: GistListViewModelOutput

    init(injector: Injectable) {

        gistListManager = injector()
        favoritesGistManager = injector()

        let showFavoritesRelay = BehaviorRelay<Bool>(value: false)

        // Select between normal list and favorite list
        let gistListStream = Observable.combineLatest(showFavoritesRelay, favoritesGistManager.favorites, gistListManager.gistListRelay)
            .map { (showFavorites, favorites, gistList) -> [Gist] in
                return showFavorites ? favorites : gistList
            }

        // Filtering gist list by owner name with inputed filter text
        let filterText = PublishRelay<String>()
        let filteredGistListRelay = Observable
            .combineLatest(gistListStream, filterText)
            .map(Filter.filterGistListByOwnerName)
            .asDriver(onErrorJustReturn: [])

        // Load gist list action
        let load = PublishRelay<Void>()
        load.bind(to: gistListManager.loadRelay)
            .disposed(by: disposeBag)

        // Prefetching logic
        let prefetchItemsAt = PublishRelay<Int>()
        prefetchItemsAt.withLatestFrom(filteredGistListRelay.map(\.count)) { row, count in
            row == count - 1 && !showFavoritesRelay.value
        }.compactMap { (shouldPrefetch) -> Void? in
            shouldPrefetch ? () : nil
        }.bind(to: gistListManager.loadRelay)
        .disposed(by: disposeBag)

        // Gist selection
        let selectedGistRelay = PublishRelay<Gist>()
        selectedGistRelay.bind(onNext: { value in
            print(value)
        }).disposed(by: disposeBag)

        self.input = Input(selectedGist: selectedGistRelay,
                           load: gistListManager.loadRelay,
                           filterText: filterText,
                           prefetchItemsAt: prefetchItemsAt,
                           showFavorites: showFavoritesRelay)
        
        self.output = Output(title: Driver.just("Gist List"),
                             gistList: filteredGistListRelay,
                             selectedGist: input.selectedGist.asSignal(),
                             isFiltering: filterText.map({ $0.isEmpty }).asDriver(onErrorJustReturn: false),
                             isFavorites: showFavoritesRelay.asDriver(onErrorJustReturn: false),
                             onError: gistListManager.errorRelay.asSignal())
    }
}

extension GistListViewModel {
    struct Input: GistListViewModelInput {
        var selectedGist: PublishRelay<Gist>
        var load: PublishRelay<Void>
        var filterText: PublishRelay<String>
        var prefetchItemsAt: PublishRelay<Int>
        var showFavorites: BehaviorRelay<Bool>
    }

    struct Output: GistListViewModelOutput {
        var title: Driver<String>
        var gistList: Driver<[Gist]>
        var selectedGist: Signal<Gist>
        var isFiltering: Driver<Bool>
        var isFavorites: Driver<Bool>
        var onError: Signal<String>
    }
}
