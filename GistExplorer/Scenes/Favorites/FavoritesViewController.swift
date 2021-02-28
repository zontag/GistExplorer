import Foundation
import UIKit
import RxSwift
import RxCocoa

final class FavoritesViewController: UICollectionViewController, Bindable {

    var viewModel: FavoritesViewModelIO?
    var disposeBag = DisposeBag()

    init() {
        super.init(collectionViewLayout: GistListFlowLayout())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    private func setupCollectionView() {
        self.collectionView.backgroundColor = .white
        self.collectionView.register(GistCell.self, forCellWithReuseIdentifier: GistCell.identifier)
        self.collectionView.allowsSelection = true
        self.collectionView.dataSource = nil
        self.collectionView.delegate = nil

    }

    func bindViewModel() {
        guard let viewModel = self.viewModel else { return }

        // Title
        viewModel.output.title
            .drive(self.rx.title)
            .disposed(by: disposeBag)

        // CollectionView Adapter
        viewModel.output.gistList
            .drive(collectionView.rx.items(cellIdentifier: GistCell.identifier)) { (_, model, cell) in
                guard let cell = cell as? GistCell else { preconditionFailure() }
                cell.prepareForReuse()
                cell.bind(to: GistCellViewModel(model: model))
            }.disposed(by: disposeBag)

        // Input
        // Item selection
        collectionView.rx.modelSelected(Gist.self)
            .do(onNext: { [weak self] _ in self?.dismiss(animated: true, completion: nil) })
            .bind(to: viewModel.input.selectedGist)
            .disposed(by: viewModel.disposeBag)
    }
}
