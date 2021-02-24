import Foundation
import UIKit
import RxSwift
import RxRelay

final class GistExplorerCoordinator: Coordinator {

    private let disposeBag = DisposeBag()
    private let presenter: UINavigationController
    private let injector: Injectable

    private let favoritesViewController = FavoritesViewController()
    private let gistDetailViewController = GistDetailViewController()

    init(presenter: UINavigationController, injector: Injectable) {
        self.presenter = presenter
        self.injector = injector
    }

    func start() {
        let vc = GistListViewController()
        let viewModel = GistListViewModel(injector: injector)
        viewModel.output.selectedGist
            .emit(onNext: navigateToDetail)
            .disposed(by: disposeBag)
        viewModel.output.showFavorites
            .emit(onNext: navigateToFavorites)
            .disposed(by: disposeBag)
        vc.bind(to: viewModel)
        presenter.show(vc, sender: nil)
    }

    private func navigateToDetail(_ gist: Gist) {
        let viewModel = GistDetailViewModel(model: gist)
        gistDetailViewController.bind(to: viewModel)
        presenter.show(gistDetailViewController, sender: nil)
    }

    private func navigateToFavorites() {
        let viewModel = FavoritesViewModel(injector: injector)
        viewModel.output.selectedGist
            .do(onNext: { [weak self] _ in self?.favoritesViewController.dismiss(animated: true, completion: nil) })
            .emit(onNext: navigateToDetail)
            .disposed(by: viewModel.disposeBag)
        favoritesViewController.bind(to: viewModel)
        presenter.present(UINavigationController(rootViewController: favoritesViewController), animated: true, completion: nil)
    }
}
