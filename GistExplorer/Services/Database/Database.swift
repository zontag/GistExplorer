import Foundation
import RxSwift
import RxRelay
import UIKit
import CoreData

protocol FavoriteDatabase {
    var save: PublishRelay<Gist> { get }
    var delete: PublishRelay<Gist> { get }
    var favorites: Infallible<[Gist]> { get }
    var persistedIDs: Infallible<[String]> { get }
}

final class FavoriteDB: FavoriteDatabase {
    private let disposeBag = DisposeBag()
    private let injector: Injectable
    private let favoritesRelay = BehaviorRelay<[Gist]>(value: [])
    private let persistedIDsRelay = BehaviorRelay<[String]>(value: [])
    private let viewContext: NSManagedObjectContext

    var save = PublishRelay<Gist>()
    var delete = PublishRelay<Gist>()
    var favorites: Infallible<[Gist]>
    var persistedIDs: Infallible<[String]>

    init(injector: Injectable) {
        self.injector = injector
        self.viewContext = injector()

        favorites = favoritesRelay.asInfallible(onErrorJustReturn: [])
        persistedIDs = persistedIDsRelay.asInfallible(onErrorJustReturn: [])

        save.observe(on: MainScheduler.instance)
            .subscribe(onNext: { (gist) in
                let fetchRequest: NSFetchRequest<GistEntity> = GistEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id==%@", gist.id.value)
                if let result = try? self.viewContext.fetch(fetchRequest) {
                    result.forEach(self.self.viewContext.delete)
                }
                _ = Map.mapGistToEnity(self.viewContext)(gist)
                self.viewContext.saveContext()
                self.dispatchFavorites()
            }).disposed(by: disposeBag)

        delete.observe(on: MainScheduler.instance)
            .subscribe(onNext: { (gist) in
                let fetchRequest: NSFetchRequest<GistEntity> = GistEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id==%@", gist.id.value)
                if let result = try? self.viewContext.fetch(fetchRequest) {
                    result.forEach(self.self.viewContext.delete)
                }
                self.viewContext.saveContext()
                self.dispatchFavorites()
            }).disposed(by: disposeBag)
        dispatchFavorites()
    }

    private func dispatchFavorites() {
        let items = fetchAll()
        favoritesRelay.accept(items)
        self.persistedIDsRelay.accept(items.map(\.id.value))
    }

    private func fetchAll() -> [Gist] {
        let fetchRequest: NSFetchRequest<GistEntity> = GistEntity.fetchRequest()
        if let result = try? self.viewContext.fetch(fetchRequest) {
            return result.map(Map.mapEntityToGist())
        }

        return []
    }
}
