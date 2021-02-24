import Foundation
import RxRelay
import RxSwift
@testable import GistExplorer

final class GistPagedListModelMock: GistPagedListModel {

    private let disposeBag = DisposeBag()

    var gistListInfallible: Infallible<[Gist]>
    var errorInfallible: Infallible<String>
    var loadRelay = PublishRelay<Void>()

    private var gistListRelay = BehaviorRelay<[Gist]>(value: [])
    private var errorRelay = PublishRelay<String>()

    var gistList: [Gist] = []
    var error: String?

    init() {
        gistListInfallible = gistListRelay.asInfallible(onErrorJustReturn: [])
        errorInfallible = errorRelay.asInfallible(onErrorJustReturn: "error")

        loadRelay
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { _ in
                if let error = self.error {
                    self.errorRelay.accept(error)
                }
                self.gistListRelay.accept(self.gistList)
            }).disposed(by: disposeBag)
    }
}
