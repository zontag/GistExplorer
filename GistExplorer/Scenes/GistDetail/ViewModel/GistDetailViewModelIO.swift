import Foundation
import RxSwift
import RxCocoa

protocol GistDetailViewModelInput {
    var selectedFile: PublishRelay<Gist.File> { get }
}

protocol GistDetailViewModelOutput {
    var ownerName: Driver<String> { get }
    var ownerImageURL: Driver<URL?> { get }
    var files: Driver<[Gist.File]> { get }
    var title: Driver<String> { get }
    var filesSectionTitle: Driver<String> { get }
    var filePreviewSectionTitle: Driver<String> { get }
    var selectedFileURL: Signal<URL?> { get }
}

protocol GistDetailViewModelIO {
    var input: GistDetailViewModelInput { get }
    var output: GistDetailViewModelOutput { get }
}
