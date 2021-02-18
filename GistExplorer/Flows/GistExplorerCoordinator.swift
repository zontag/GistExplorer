import Foundation
import UIKit

final class GistExplorerCoordinator: Coordinator {

    var presenter: UINavigationController
    var injector: Injectable

    init(presenter: UINavigationController, injector: Injectable) {
        self.presenter = presenter
        self.injector = injector
    }

    func start() {
        presenter.show(GistListViewController(), sender: nil)
    }
}
