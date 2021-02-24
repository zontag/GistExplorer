import Foundation
import RxSwift
import RxCocoa

protocol GistListViewModelInput {
    var selectedGist: PublishRelay<Gist> { get }
    var filterText: PublishRelay<String> { get }
    var load: PublishRelay<Void> { get }
    var prefetchItemsAt: PublishRelay<Int> { get }
    var showFavorites: PublishRelay<Void> { get }
}

protocol GistListViewModelOutput {
    var gistList: Driver<[Gist]> { get }
    var title: Driver<String> { get }
    var selectedGist: Signal<Gist> { get }
    var onError: Signal<String> { get }
    var showFavorites: Signal<Void> { get }
}

protocol GistListViewModelIO {
    var disposeBag: DisposeBag { get }
    var input: GistListViewModelInput { get }
    var output: GistListViewModelOutput { get }
}
