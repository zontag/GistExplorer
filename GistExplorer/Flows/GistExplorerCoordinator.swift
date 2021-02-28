import Foundation
import UIKit
import RxSwift
import RxRelay

final class GistExplorerCoordinator: Coordinator {

    private let disposeBag = DisposeBag()
    private let presenter: UINavigationController

    var favoritesDB: FavoriteDatabase
    var gistPagedList: GistPagedListModel

    init(presenter: UINavigationController,
         favoritesDB: FavoriteDatabase,
         gistPagedList: GistPagedListModel) {
        self.presenter = presenter
        self.favoritesDB = favoritesDB
        self.gistPagedList = gistPagedList
    }

    func start() {
        let vc = GistListViewController()
        let viewModel = GistListViewModel(model: gistPagedList, database: favoritesDB)
        viewModel.output.selectedGist
            .emit(with: self, onNext: { (owner, gist) in
                owner.navigateToDetail(gist)
            }).disposed(by: disposeBag)
        viewModel.output.showFavorites
            .emit(with: self, onNext: { (owner, _) in owner.navigateToFavorites() })
            .disposed(by: disposeBag)
        vc.bind(to: viewModel)
        presenter.show(vc, sender: nil)
    }

    private func navigateToDetail(_ gist: Gist) {
        let gistDetailViewController = GistDetailViewController()
        let viewModel = GistDetailViewModel(model: gist)
        gistDetailViewController.bind(to: viewModel)
        presenter.show(gistDetailViewController, sender: nil)
    }

    private func navigateToFavorites() {
        let favoritesViewController = FavoritesViewController()
        let viewModel = FavoritesViewModel(favoriteDB: favoritesDB)
        viewModel.output.selectedGist
            .emit(with: self, onNext: { (owner, gist) in
                owner.navigateToDetail(gist)
            }).disposed(by: viewModel.disposeBag)
        favoritesViewController.bind(to: viewModel)
        presenter.present(UINavigationController(rootViewController: favoritesViewController), animated: true, completion: nil)
    }
}
