import Foundation
import RxSwift
import RxCocoa

final class GistCellViewModel: GistCellViewModelIO {

    let disposeBag = DisposeBag()

    var input: GistCellViewModelInput

    var output: GistCellViewModelOutput

    struct Input: GistCellViewModelInput {
        var favorite: PublishRelay<Void>
    }

    struct Output: GistCellViewModelOutput {
        var ownerName: Driver<String>
        var ownerImageURL: Driver<URL?>
        var gistType: Driver<String>
        var isFavorite: Driver<Bool>
    }

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
