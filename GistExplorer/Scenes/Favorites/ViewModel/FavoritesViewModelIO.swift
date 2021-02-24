import Foundation
import RxCocoa
import RxSwift

protocol FavoritesViewModelInput {
    var selectedGist: PublishRelay<Gist> { get }
}

protocol FavoritesViewModelOutput {
    var selectedGist: Signal<Gist> { get }
    var gistList: Driver<[Gist]> { get }
    var title: Driver<String> { get }
}

protocol FavoritesViewModelIO {
    var disposeBag: DisposeBag { get }
    var input: FavoritesViewModelInput { get }
    var output: FavoritesViewModelOutput { get }
}
