import Foundation
import RxRelay
import RxSwift
@testable import GistExplorer

final class FavoritesGistModelMock: FavoritesGistModel {
    private let disposeBag = DisposeBag()

    var save = PublishRelay<Gist>()
    var delete = PublishRelay<Gist>()
    var favorites = BehaviorRelay<[Gist]>(value: [])

    var gistList: [Gist] = [] {
        didSet {
            self.favorites.accept(self.gistList)
        }
    }

    init() {
        save.bind { (gist) in
            self.gistList.append(gist)
        }.disposed(by: disposeBag)

        delete.bind { (gist) in
            if let index = self.gistList.firstIndex(where: { $0 == gist }) {
                self.gistList.remove(at: index)
            }
        }.disposed(by: disposeBag)

        self.favorites.accept(self.gistList)
    }
}
