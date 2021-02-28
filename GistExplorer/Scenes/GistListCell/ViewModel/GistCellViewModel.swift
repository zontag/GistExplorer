import Foundation
import RxSwift
import RxCocoa

final class GistCellViewModel: GistCellViewModelIO {

    var disposeBag = DisposeBag()

    var input: GistCellViewModelInput
    var output: GistCellViewModelOutput

    init(model: Gist) {
        let favoriteRelay = PublishRelay<Void>()
        favoriteRelay.bind(to: model.favorite).disposed(by: disposeBag)

        self.input = Input(favorite: favoriteRelay)
        self.output = Output(ownerName: model.ownerName.compactMap(Map.mapSelf).asDriver(onErrorJustReturn: ""),
                             ownerImageURL: model.ownerImage.asDriver(),
                             gistType: model.files.compactMap({ $0?.first?.type.value }).asDriver(onErrorJustReturn: ""),
                             isFavorite: model.isFavorite.asDriver(onErrorJustReturn: false))
    }
}

extension GistCellViewModel {
    struct Input: GistCellViewModelInput {
        var favorite: PublishRelay<Void>
    }

    struct Output: GistCellViewModelOutput {
        var ownerName: Driver<String>
        var ownerImageURL: Driver<URL?>
        var gistType: Driver<String>
        var isFavorite: Driver<Bool>
    }
}
