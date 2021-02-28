import Foundation
import UIKit

protocol Coordinator {
    func start()
}

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let navigationController = UINavigationController()

    private lazy var githubNetwork: GithubNetworkDispatchable = {
        GithubNetworkDispatcher(networkDispatcher: URLSession.shared)
    }()

    private lazy var favoritesDB: FavoriteDatabase = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            preconditionFailure()
        }
        let viewContext = appDelegate.persistentContainer.viewContext
        return FavoriteDB(viewContext: viewContext)
    }()

    private lazy var gistPagedList: GistPagedListModel = {
        GistPagedList(limit: 30, githubNetwork: self.githubNetwork)
    }()

    private var gistExplorerCoordinator: GistExplorerCoordinator?
    
    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.gistExplorerCoordinator = GistExplorerCoordinator(presenter: navigationController,
                                                               favoritesDB: favoritesDB,
                                                               gistPagedList: gistPagedList)
        gistExplorerCoordinator?.start()
    }
}
