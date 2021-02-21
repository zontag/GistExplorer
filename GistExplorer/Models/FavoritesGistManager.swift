import Foundation
import RxSwift
import RxRelay

protocol FavoritesGistModel {
    var database: FavoriteDatabase { get }
    var save: PublishRelay<Gist> { get }
    var delete: PublishRelay<Gist> { get }
    var favorites: BehaviorRelay<[Gist]> { get }
}

final class FavoritesGistManager: FavoritesGistModel {
    private let disposeBag = DisposeBag()

    var database: FavoriteDatabase
    var favorites = BehaviorRelay<[Gist]>(value: [])
    var save = PublishRelay<Gist>()
    var delete = PublishRelay<Gist>()

    init(injector: Injectable) {
        self.database = injector()

        self.save.bind(to: database.save).disposed(by: disposeBag)
        self.delete.bind(to: database.delete).disposed(by: disposeBag)
        database.favorites.bind(to: favorites).disposed(by: disposeBag)
    }
}
