import Foundation
import UIKit
import CoreData

protocol Injectable {
    func callAsFunction<T>() -> T
}

final class Injector: Injectable {

    private var services: [ObjectIdentifier: Any] = [:]

    func callAsFunction<T>() -> T {
        guard let dependency = services[key(for: T.self)] as? T
        else {
            preconditionFailure("Dependency not properly registered")
        }
        return dependency
    }

    func register<T>(_ service: T) {
        services[key(for: T.self)] = service
    }

    private func key<T>(for type: T.Type) -> ObjectIdentifier {
        return ObjectIdentifier(T.self)
    }
}

extension Injector {
    static var appInjector: Injector {
        let injector = Injector()

        if let viewContent = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            injector.register(viewContent as NSManagedObjectContext)
        }

        injector.register(GithubNetworkDispatcher(networkDispatcher: URLSession.shared) as GithubNetworkDispatchable)

        injector.register(GistPagedList(limit: 30, injector: injector) as GistPagedListModel)

        injector.register(FavoriteDB(injector: injector) as FavoriteDatabase)

        injector.register(FavoritesGistManager(injector: injector) as FavoritesGistModel)

        return injector
    }
}
