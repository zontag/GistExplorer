import Foundation
import RxSwift
import RxCocoa

protocol GistCellViewModelInput {
    var favorite: PublishRelay<Void> { get }
}

protocol GistCellViewModelOutput {
    var ownerName: Driver<String> { get }
    var ownerImageURL: Driver<URL?> { get }
    var gistType: Driver<String> { get }
    var isFavorite: Driver<Bool> { get }
}

protocol GistCellViewModelIO {
    var disposeBag: DisposeBag { get }
    var input: GistCellViewModelInput { get }
    var output: GistCellViewModelOutput { get }

    func prepareForReuse()
}
