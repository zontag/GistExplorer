import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

final class GistCell: UICollectionViewCell, Bindable {

    private var disposeBag: DisposeBag?

    var viewModel: GistCellViewModelIO?

    static let identifier = String(describing: GistCell.self)

    var view = GistCellView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(view)
        contentView.backgroundColor = .white
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }

    func bindViewModel() {
        guard let viewModel = self.viewModel else { return }
        self.disposeBag = DisposeBag()
        disposeBag?.insert {
            viewModel.output.gistType.drive(view.gistTypeLabel.rx.text)
            viewModel.output.ownerName.drive(view.ownerNameLabel.rx.text)
            viewModel.output.ownerImageURL.compactMap(Map.mapSelf).map({ KF.url($0) }).drive(view.ownerImageView.rx.kfBuilder)
            viewModel.output.isFavorite.distinctUntilChanged()
                .drive(onNext: view.setupFavoriteButton)
            view.favoriteSwitch.rx.tap
                .asSignal(onErrorJustReturn: ()).emit(to: viewModel.input.favorite)
        }
    }

}
