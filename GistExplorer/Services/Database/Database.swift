import Foundation
import RxSwift
import RxRelay
import UIKit
import CoreData

protocol FavoriteDatabase {
    var save: PublishRelay<Gist> { get }
    var delete: PublishRelay<Gist> { get }
    var favorites: BehaviorRelay<[Gist]> { get }
}

final class FavoriteDB: FavoriteDatabase {
    private let disposeBag = DisposeBag()

    var save = PublishRelay<Gist>()
    var delete = PublishRelay<Gist>()
    var favorites = BehaviorRelay<[Gist]>(value: [])

    init(injector: Injectable) {

        let viewContext: NSManagedObjectContext = injector()

        save.observe(on: MainScheduler.instance)
            .map(Map.mapGistToEnity(viewContext))
            .subscribe(onNext: { (_) in
                viewContext.saveContext()
                self.fetchAll(injector, viewContext)
            }).disposed(by: disposeBag)

        delete.observe(on: MainScheduler.instance)
            .subscribe(onNext: { (gist) in
                let fetchRequest: NSFetchRequest<GistEntity> = GistEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id==%@", gist.id.value)
                if let result = try? viewContext.fetch(fetchRequest) {
                    result.forEach(viewContext.delete)
                }
                viewContext.saveContext()
                self.fetchAll(injector, viewContext)
            }).disposed(by: disposeBag)

        self.fetchAll(injector, viewContext)
    }

    private func fetchAll(_ injector: Injectable, _ viewContext: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<GistEntity> = GistEntity.fetchRequest()
        if let result = try? viewContext.fetch(fetchRequest) {
            favorites.accept(result.map(Map.mapEntityToGist(injector)))
        }
    }
}
