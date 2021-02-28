import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class GistDetailViewController: UIViewController, Bindable {

    private let disposeBag = DisposeBag()
    private let contentView = GistDetailView()

    var viewModel: GistDetailViewModelIO?

    override func loadView() {
        view = contentView
    }

    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        contentView.filesTableView.dataSource = nil
        contentView.filesTableView.delegate = nil
            // Input
        contentView.filesTableView.rx.modelSelected(Gist.File.self)
            .bind(to: viewModel.input.selectedFile)
            .disposed(by: disposeBag)
        // Output
        viewModel.output.title.drive(self.rx.title).disposed(by: disposeBag)
        viewModel.output.filesSectionTitle.drive(self.contentView.filesLabel.rx.text).disposed(by: disposeBag)
        viewModel.output.filePreviewSectionTitle.drive(self.contentView.filesPreviewLabel.rx.text).disposed(by: disposeBag)
        viewModel.output.ownerName.drive(self.contentView.ownerNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.output.ownerImageURL.compactMap(Map.mapSelf).map({ KF.url($0) })
            .drive(self.contentView.ownerImageView.rx.kfBuilder).disposed(by: disposeBag)
        viewModel.output.selectedFileURL.asObservable().bind(to: self.contentView.webView.rx.url).disposed(by: disposeBag)
        viewModel.output.files.drive(self.contentView.filesTableView.rx.items(cellIdentifier: "Cell")) { [weak self] _, model, cell in
            guard let self = self else { return }
            guard let textBinder = cell.textLabel?.rx.text else { return }
            model.name.asDriver().drive(textBinder).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
}
