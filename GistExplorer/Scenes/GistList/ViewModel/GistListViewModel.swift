import Foundation
import RxSwift
import RxCocoa

final class GistListViewModel: GistListViewModelIO {

    let disposeBag = DisposeBag()
    var input: GistListViewModelInput
    var output: GistListViewModelOutput

    init(model: GistPagedListModel, database: FavoriteDatabase) {

        let showFavoritesRelay = PublishRelay<Void>()

        // Filtering gist list by owner name with inputed filter text
        let filterText = PublishRelay<String>()
        let filteredGistListRelay = Observable
            .combineLatest(model.gistListInfallible.asObservable(), filterText)
            .map(Filter.filterGistListByOwnerName)
            .map({ (list) -> [Gist] in
                return list.map { (item) -> Gist in
                    item.favoriteDB = database
                    return item
                }
            })
            .asDriver(onErrorJustReturn: [])

        // Load gist list action
        let load = PublishRelay<Void>()
        load.bind(to: model.loadRelay)
            .disposed(by: disposeBag)

        // Prefetching logic
        let prefetchItemsAt = PublishRelay<Int>()
        prefetchItemsAt.withLatestFrom(filteredGistListRelay.map(\.count)) { row, count in
            row == count - 1
        }.compactMap { (shouldPrefetch) -> Void? in shouldPrefetch ? () : nil
        }.bind(to: model.loadRelay)
        .disposed(by: disposeBag)

        // Gist selection
        let selectedGistRelay = PublishRelay<Gist>()

        self.input = Input(selectedGist: selectedGistRelay,
                           load: model.loadRelay,
                           filterText: filterText,
                           prefetchItemsAt: prefetchItemsAt,
                           showFavorites: showFavoritesRelay)
        
        self.output = Output(title: Driver.just("Gist List"),
                             gistList: filteredGistListRelay,
                             selectedGist: input.selectedGist.asSignal(),
                             onError: model.errorInfallible.asSignal(onErrorJustReturn: ""),
                             showFavorites: showFavoritesRelay.asSignal())
    }
}

extension GistListViewModel {
    struct Input: GistListViewModelInput {
        var selectedGist: PublishRelay<Gist>
        var load: PublishRelay<Void>
        var filterText: PublishRelay<String>
        var prefetchItemsAt: PublishRelay<Int>
        var showFavorites: PublishRelay<Void>
    }

    struct Output: GistListViewModelOutput {
        var title: Driver<String>
        var gistList: Driver<[Gist]>
        var selectedGist: Signal<Gist>
        var onError: Signal<String>
        var showFavorites: Signal<Void>
    }
}
