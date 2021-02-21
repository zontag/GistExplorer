import Foundation
import UIKit
import RxSwift
import RxRelay

final class GistExplorerCoordinator: Coordinator {

    private let disposeBag = DisposeBag()
    private let gistDetailNavigation = PublishRelay<Gist>()
    private let presenter: UINavigationController
    private let injector: Injectable

    init(presenter: UINavigationController, injector: Injectable) {
        self.presenter = presenter
        self.injector = injector
        bind()
    }

    private func bind() {
        gistDetailNavigation
            .asSignal()
            .asObservable()
            .subscribe(onNext: navigateToDetail)
            .disposed(by: disposeBag)
    }

    func start() {
        let vc = GistListViewController()
        let viewModel = GistListViewModel(injector: injector)
        viewModel.output.selectedGist.emit(to: gistDetailNavigation).disposed(by: disposeBag)
        vc.bind(to: viewModel)
        presenter.show(vc, sender: nil)
    }

    private func navigateToDetail(_ gist: Gist) {
        let vc = GistDetailViewController()
        let viewModel = GistDetailViewModel(model: gist)
        vc.bind(to: viewModel)
        presenter.show(vc, sender: nil)
    }
}
