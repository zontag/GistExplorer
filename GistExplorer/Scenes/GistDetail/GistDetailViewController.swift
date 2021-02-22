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
        disposeBag.insert {
            // Input
            contentView.filesTableView.rx.modelSelected(Gist.File.self).bind(to: viewModel.input.selectedFile)
            // Output
            viewModel.output.title.drive(self.rx.title)
            viewModel.output.filesSectionTitle.drive(contentView.filesLabel.rx.text)
            viewModel.output.filePreviewSectionTitle.drive(contentView.filesPreviewLabel.rx.text)
            viewModel.output.ownerName.drive(contentView.ownerNameLabel.rx.text)
            viewModel.output.ownerImageURL.compactMap(Map.mapSelf).map({ KF.url($0) })
                .drive(contentView.ownerImageView.rx.kfBuilder)
            viewModel.output.selectedFileURL.asObservable().bind(to: contentView.webView.rx.url)
            viewModel.output.files.drive(contentView.filesTableView.rx.items(cellIdentifier: "Cell")) { _, model, cell in
                guard let textBinder = cell.textLabel?.rx.text else { return }
                model.name.asDriver().drive(textBinder).disposed(by: self.disposeBag)
            }
        }
    }
}
