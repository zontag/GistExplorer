import Foundation
import UIKit
import RxSwift
import RxRelay

final class GistExplorerCoordinator: Coordinator {

    private let disposeBag = DisposeBag()
    private let presenter: UINavigationController
    private let injector: Injectable

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
        let vc = GistDetailViewController()
        let viewModel = GistDetailViewModel(model: gist)
        vc.bind(to: viewModel)
        presenter.show(vc, sender: nil)
    }

    private func navigateToFavorites() {
        let vc = FavoritesViewController()
        let viewModel = FavoritesViewModel(injector: injector)
        viewModel.output.selectedGist
            .do(onNext: { _ in vc.dismiss(animated: true, completion: nil) })
            .emit(onNext: navigateToDetail)
            .disposed(by: disposeBag)
        vc.bind(to: viewModel)
        presenter.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}
