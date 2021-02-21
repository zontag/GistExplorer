import Foundation
import RxSwift
import RxCocoa

protocol GistCellViewModelInput {
    var favorite: PublishRelay<Bool> { get }
}

protocol GistCellViewModelOutput {
    var ownerName: Driver<String> { get }
    var ownerImageURL: Driver<URL?> { get }
    var gistType: Driver<String> { get }
    var isFavorite: Driver<Bool> { get }
}

protocol GistCellViewModelIO {
    var input: GistCellViewModelInput { get }
    var output: GistCellViewModelOutput { get }
}
