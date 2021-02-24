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
        unowned let vc = self
        vc.contentView.filesTableView.dataSource = nil
        viewModel.disposeBag.insert {
            // Input
            vc.contentView.filesTableView.rx.modelSelected(Gist.File.self).bind(to: viewModel.input.selectedFile)
            // Output
            viewModel.output.title.drive(vc.rx.title)
            viewModel.output.filesSectionTitle.drive(vc.contentView.filesLabel.rx.text)
            viewModel.output.filePreviewSectionTitle.drive(vc.contentView.filesPreviewLabel.rx.text)
            viewModel.output.ownerName.drive(vc.contentView.ownerNameLabel.rx.text)
            viewModel.output.ownerImageURL.compactMap(Map.mapSelf).map({ KF.url($0) })
                .drive(vc.contentView.ownerImageView.rx.kfBuilder)
            viewModel.output.selectedFileURL.asObservable().bind(to: vc.contentView.webView.rx.url)
            viewModel.output.files.drive(vc.contentView.filesTableView.rx.items(cellIdentifier: "Cell")) { _, model, cell in
                guard let textBinder = cell.textLabel?.rx.text else { return }
                model.name.asDriver().drive(textBinder).disposed(by: viewModel.disposeBag)
            }
        }
    }
}
