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
    private let favoritesRelay = BehaviorRelay<[Gist]>(value: [])
    private let persistedIDsRelay = BehaviorRelay<[String]>(value: [])

    var save = PublishRelay<Gist>()
    var delete = PublishRelay<Gist>()
    var favorites: Infallible<[Gist]>
    var persistedIDs: Infallible<[String]>

    init(viewContext: NSManagedObjectContext) {
        favorites = favoritesRelay.asInfallible(onErrorJustReturn: [])
        persistedIDs = persistedIDsRelay.asInfallible(onErrorJustReturn: [])

        save.observe(on: MainScheduler.instance)
            .subscribe(onNext: { (gist) in
                let fetchRequest: NSFetchRequest<GistEntity> = GistEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id==%@", gist.id.value)
                if let result = try? viewContext.fetch(fetchRequest) {
                    result.forEach(viewContext.delete)
                }
                _ = Map.mapGistToEnity(viewContext)(gist)
                viewContext.saveContext()
                self.dispatchFavorites(viewContext)
            }).disposed(by: disposeBag)

        delete.observe(on: MainScheduler.instance)
            .subscribe(onNext: { (gist) in
                let fetchRequest: NSFetchRequest<GistEntity> = GistEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id==%@", gist.id.value)
                if let result = try? viewContext.fetch(fetchRequest) {
                    result.forEach(viewContext.delete)
                }
                viewContext.saveContext()
                self.dispatchFavorites(viewContext)
            }).disposed(by: disposeBag)
        dispatchFavorites(viewContext)
    }

    private func dispatchFavorites(_ viewContext: NSManagedObjectContext) {
        let items = fetchAll(viewContext)
        favoritesRelay.accept(items)
        self.persistedIDsRelay.accept(items.map(\.id.value))
    }

    private func fetchAll(_ viewContext: NSManagedObjectContext) -> [Gist] {
        let fetchRequest: NSFetchRequest<GistEntity> = GistEntity.fetchRequest()
        if let result = try? viewContext.fetch(fetchRequest) {
            return result.map(Map.mapEntityToGist())
        }

        return []
    }
}
