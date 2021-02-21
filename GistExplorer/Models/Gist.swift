import Foundation
import RxSwift
import RxRelay

final class Gist {

    private let disposeBag = DisposeBag()
    private let favoritesGistManager: FavoritesGistModel

    let id: BehaviorRelay<String>
    let ownerName: BehaviorRelay<String?>
    let ownerImage: BehaviorRelay<URL?>
    let files: BehaviorRelay<[File]?>
    let isFavorite = BehaviorRelay<Bool>(value: false)
    let favorite = PublishRelay<Bool>()

    init(injector: Injectable, id: String, ownerName: String?, ownerImage: URL?, files: [File]?) {
        self.id = .init(value: id)
        self.ownerName = .init(value: ownerName)
        self.ownerImage = .init(value: ownerImage)
        self.files = .init(value: files)
        self.favoritesGistManager = injector()

        favoritesGistManager.favorites.map { (list) -> Bool in
            list.contains(where: { $0.id.value == self.id.value })
        }.bind(to: isFavorite).disposed(by: disposeBag)

        favorite
            .filter(Map.mapSelf)
            .map({ _ in self })
            .bind(to: self.favoritesGistManager.save)
            .disposed(by: disposeBag)

        favorite
            .filter { !$0 }
            .map({ _ in self })
            .bind(to: self.favoritesGistManager.delete)
            .disposed(by: disposeBag)

    }

}

extension Gist {
    struct File {
        let name: BehaviorRelay<String?>
        let type: BehaviorRelay<String?>
        let url: BehaviorRelay<URL?>
        let size: BehaviorRelay<Int?>
        let language: BehaviorRelay<String?>

        init(name: String?, type: String?, url: URL?, size: Int?, language: String?) {
            self.name = .init(value: name)
            self.type = .init(value: type)
            self.url = .init(value: url)
            self.size = .init(value: size)
            self.language = .init(value: language)
        }
    }
}
