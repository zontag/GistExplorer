import Foundation
import RxRelay
import RxSwift
@testable import GistExplorer

final class FavoriteDatabaseMock: FavoriteDatabase {
    private let disposeBag = DisposeBag()

    private var favoritesRelay = BehaviorRelay<[Gist]>(value: [])
    private var persistedIDsRelay = BehaviorRelay<[String]>(value: [])

    var favorites: Infallible<[Gist]>
    var save = PublishRelay<Gist>()
    var delete = PublishRelay<Gist>()
    var persistedIDs: Infallible<[String]>

    var gistList: [Gist] = [] {
        didSet {
            self.favoritesRelay.accept(self.gistList)
        }
    }

    init() {
        favorites = favoritesRelay.asInfallible(onErrorJustReturn: [])
        persistedIDs = persistedIDsRelay.asInfallible(onErrorJustReturn: [])
        
        save.bind { (gist) in
            self.gistList.append(gist)
        }.disposed(by: disposeBag)

        delete.bind { (gist) in
            if let index = self.gistList.firstIndex(where: { $0 == gist }) {
                self.gistList.remove(at: index)
            }
        }.disposed(by: disposeBag)

        self.favoritesRelay.accept(self.gistList)
    }
}
