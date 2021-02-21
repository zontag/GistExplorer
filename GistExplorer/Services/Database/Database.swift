import Foundation
import RxSwift
import RxRelay
import UIKit
import RealmSwift
import RxRealm

protocol FavoriteDatabase {
    var save: PublishRelay<Gist> { get }
    var delete: PublishRelay<Gist> { get }
    var favorites: BehaviorRelay<[Gist]> { get }
}

final class RealmFavoriteDB: FavoriteDatabase {
    private let disposeBag = DisposeBag()

    var save = PublishRelay<Gist>()
    var delete = PublishRelay<Gist>()
    var favorites = BehaviorRelay<[Gist]>(value: [])

    init(injector: Injectable) {
        save.map(Map.mapGistToEnity)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (entity) in
                guard let realm = try? Realm() else { return }
                try? realm.write { realm.add(entity) }
            }).disposed(by: disposeBag)

        delete.observe(on: MainScheduler.instance)
            .subscribe(onNext: { (gist) in
                guard let realm = try? Realm() else { return }
                try? realm.write {
                    if let entity = realm.objects(GistEntity.self).first(where: { $0.id == gist.id.value }) {
                        realm.delete(entity)
                    }
                }
            }).disposed(by: disposeBag)

        guard let realm = try? Realm() else { return }
        let favoritesResults = realm.objects(GistEntity.self)

        Observable.collection(from: favoritesResults, synchronousStart: false)
            .map { $0.map(Map.mapEntityToGist(injector)) }
            .bind(to: favorites)
            .disposed(by: disposeBag)
    }
}
