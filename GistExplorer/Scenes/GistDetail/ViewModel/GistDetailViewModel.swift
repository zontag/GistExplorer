import Foundation
import RxSwift
import RxCocoa

final class GistDetailViewModel: GistDetailViewModelIO {

    var disposeBag = DisposeBag()
    var input: GistDetailViewModelInput
    var output: GistDetailViewModelOutput

    init(model: Gist) {
        let selectedFile = PublishRelay<Gist.File>()

        self.input = Input(selectedFile: selectedFile)
        self.output = Output(title: model.ownerName.compactMap(Map.mapSelf).asDriver(onErrorJustReturn: "Gist Detail"),
                             filesSectionTitle: Driver.just("Files"),
                             filePreviewSectionTitle: Driver.just("File Preview"),
                             ownerName: model.ownerName.compactMap(Map.mapSelf).asDriver(onErrorJustReturn: ""),
                             ownerImageURL: model.ownerImage.asDriver(),
                             files: model.files.compactMap(Map.mapSelf).asDriver(onErrorJustReturn: []),
                             selectedFileURL: input.selectedFile.asSignal().map(\.url).map(\.value))
    }
}

extension GistDetailViewModel {
    struct Input: GistDetailViewModelInput {
        var selectedFile: PublishRelay<Gist.File>
    }

    struct Output: GistDetailViewModelOutput {
        var title: Driver<String>
        var filesSectionTitle: Driver<String>
        var filePreviewSectionTitle: Driver<String>
        var ownerName: Driver<String>
        var ownerImageURL: Driver<URL?>
        var files: Driver<[Gist.File]>
        var selectedFileURL: Signal<URL?>
    }
}
