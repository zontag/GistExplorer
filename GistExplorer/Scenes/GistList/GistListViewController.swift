import UIKit
import RxSwift
import RxCocoa

final class GistListViewController: UICollectionViewController, Bindable {

    var viewModel: GistListViewModelIO?
    private var disposeBag = DisposeBag()
    private lazy var favoriteButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: nil)
    private var searchBar: UISearchBar?
    private var gistList: [Gist] = []

    init() {
        super.init(collectionViewLayout: GistListFlowLayout())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFavoriteFilter()
        setupSearchView()
        setupCollectionView()
    }

    private func setupFavoriteFilter() {
        favoriteButton.tintColor = .appMediumGray
        navigationItem.setRightBarButton(favoriteButton, animated: false)
    }

    private func setupSearchView() {
        searchBar = UISearchBar()
        navigationItem.titleView = searchBar
    }

    private func setupCollectionView() {
        self.collectionView.backgroundColor = .white
        self.collectionView.register(GistCell.self, forCellWithReuseIdentifier: GistCell.identifier)
        self.collectionView.dataSource = nil
        self.collectionView.allowsSelection = true
        self.collectionView.keyboardDismissMode = .onDrag
    }

    // MARK: - Bindable
    func bindViewModel() {
        guard let viewModel = self.viewModel else { return }

        // Output
        // Title
        viewModel.output.title
            .drive(self.rx.title)
            .disposed(by: disposeBag)

        // CollectionView Adapter
        viewModel.output.gistList
            .drive(self.collectionView.rx.items(cellIdentifier: GistCell.identifier)) { (_, model, cell) in
                guard let cell = cell as? GistCell else { preconditionFailure() }
                cell.prepareForReuse()
                cell.bind(to: GistCellViewModel(model: model))
            }.disposed(by: disposeBag)

        // Handle error
        viewModel.output.onError.emit(with: self, onNext: { `vc`, _ in
            let actionController = UIAlertController(title: "Ops..", message: "Sorry, something wrong is not right.", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                viewModel.input.load.accept(())
            }
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel)
            actionController.addAction(retryAction)
            actionController.addAction(cancelAction)
           vc.present(actionController, animated: true, completion: nil)
        }).disposed(by: disposeBag)

        // Input
        // Item selection
        collectionView.rx.modelSelected(Gist.self)
            .bind(to: viewModel.input.selectedGist)
            .disposed(by: disposeBag)

        // CollectionView Prefetch Items
        collectionView.rx.prefetchItems
            .compactMap(\.last)
            .map(\.row)
            .bind(to: viewModel.input.prefetchItemsAt)
            .disposed(by: disposeBag)

        // Navigatonbar favorite button tap action
        favoriteButton.rx.tap.bind(to: viewModel.input.showFavorites)
        .disposed(by: disposeBag)

        // Searchbar text change
        searchBar?.rx.text.orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(to: viewModel.input.filterText)
            .disposed(by: disposeBag)

        viewModel.input.load.accept(())
    }
}
