import Foundation
import RxSwift
import RxRelay

final class Gist {

    private let disposeBag = DisposeBag()

    var favoriteDB: FavoriteDatabase? { didSet { bindFavoriteDB() } }

    let id: BehaviorRelay<String>
    let ownerName: BehaviorRelay<String?>
    let ownerImage: BehaviorRelay<URL?>
    let files: BehaviorRelay<[File]?>
    let isFavorite = BehaviorRelay<Bool>(value: false)
    let favorite = PublishRelay<Void>()

    init(id: String, ownerName: String?, ownerImage: URL?, files: [File]?) {
        self.id = .init(value: id)
        self.ownerName = .init(value: ownerName)
        self.ownerImage = .init(value: ownerImage)
        self.files = .init(value: files)
    }

    private func bindFavoriteDB() {
        guard let favoriteDB = self.favoriteDB else {
            preconditionFailure()
        }

        favoriteDB.persistedIDs
            .map { (ids) -> Bool in
                ids.contains(self.id.value)
            }.bind(to: self.isFavorite)
            .disposed(by: disposeBag)

        favorite
            .map({ self.isFavorite.value })
            .bind(onNext: { isFav in
                if isFav {
                    favoriteDB.delete.accept(self)
                } else {
                    favoriteDB.save.accept(self)
                }
            }).disposed(by: disposeBag)
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

extension Gist {
    enum UseCase { }
}

extension Gist.UseCase {
    struct GetFavorites {
        let injector: Injectable

        func callAsFunction() -> Infallible<[Gist]> {
            let favoriteDB: FavoriteDatabase = injector()
            return favoriteDB.favorites
        }
    }
}

extension Gist: Equatable {
    static func == (lhs: Gist, rhs: Gist) -> Bool {
        lhs.id.value == rhs.id.value
    }
}

extension Gist.File: Equatable {
    static func == (lhs: Gist.File, rhs: Gist.File) -> Bool {
        lhs.url.value == rhs.url.value
            && lhs.name.value == rhs.name.value
            && lhs.size.value == rhs.size.value
    }

}
