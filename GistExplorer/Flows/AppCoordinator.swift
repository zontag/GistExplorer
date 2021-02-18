import Foundation
import UIKit

protocol Coordinator {
    func start()
}

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let navigationController = UINavigationController()
    private var gistExplorerCoordinator: GistExplorerCoordinator?

    var injector: Injectable = {
        let injector = Injector()
        return injector
    }()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.gistExplorerCoordinator = GistExplorerCoordinator(presenter: navigationController, injector: injector)
        gistExplorerCoordinator?.start()
    }
}
