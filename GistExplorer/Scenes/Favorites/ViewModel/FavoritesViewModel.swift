import Foundation
import RxSwift
import RxCocoa

final class FavoritesViewModel: FavoritesViewModelIO {
    var disposeBag = DisposeBag()
    var input: FavoritesViewModelInput
    var output: FavoritesViewModelOutput

    init(favoriteDB: FavoriteDatabase) {

        // Gist selection
        let selectedGistRelay = PublishRelay<Gist>()

        let getFavoritesUseCase = Gist.UseCase.GetFavorites(favoriteDB: favoriteDB)()
        .map({ (list) -> [Gist] in
            return list.map { (item) -> Gist in
                let database: FavoriteDatabase = favoriteDB
                item.favoriteDB = database
                return item
            }
        }).asDriver(onErrorJustReturn: [])

        self.input = Input(selectedGist: selectedGistRelay)

        self.output = Output(selectedGist: input.selectedGist.asSignal(),
                             gistList: getFavoritesUseCase,
                             title: Driver.just("Favorites"))
    }
}

extension FavoritesViewModel {
    struct Input: FavoritesViewModelInput {
        var selectedGist: PublishRelay<Gist>
    }

    struct Output: FavoritesViewModelOutput {
        var selectedGist: Signal<Gist>
        var gistList: Driver<[Gist]>
        var title: Driver<String>
    }
}
