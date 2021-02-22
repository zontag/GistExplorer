//
//  GistExplorerTests.swift
//  GistExplorerTests
//
//  Created by Tiago Zontag on 21/02/21.
//

import XCTest
@testable import GistExplorer
import RxTest
import RxRelay
import RxBlocking
import RxSwift

// swiftlint:disable overridden_super_call implicitly_unwrapped_optional
class GistExplorerTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    let injector = Injector()

    class FavoriteDatabaseMock: FavoriteDatabase {
        var save = PublishRelay<Gist>()

        var delete = PublishRelay<Gist>()

        var favorites = BehaviorRelay<[Gist]>(value: [])
    }

    class FavoritesGistModelMock: FavoritesGistModel {
        private let disposeBag = DisposeBag()
        var database: FavoriteDatabase = FavoriteDatabaseMock()

        var save = PublishRelay<Gist>()
        var delete = PublishRelay<Gist>()
        var favorites = BehaviorRelay<[Gist]>(value: [])

        var gistList: [Gist] = []

        init() {
            save.bind { (gist) in
                self.gistList.append(gist)
                self.favorites.accept(self.gistList)
            }.disposed(by: disposeBag)

            delete.bind { (gist) in
                if let index = self.gistList.firstIndex(where: { $0 == gist }) {
                    self.gistList.remove(at: index)
                    self.favorites.accept(self.gistList)
                }
            }.disposed(by: disposeBag)
        }

    }

    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        injector.register(FavoriteDatabaseMock() as FavoriteDatabase)
        injector.register(FavoritesGistModelMock() as FavoritesGistModel)
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {

        // Given
        let isFavorite = scheduler.createObserver(Bool.self)

        let file = Gist.File(name: "File Name", type: ".swift", url: nil, size: 0, language: "swift")
        let gist = Gist(injector: injector, id: "123", ownerName: "Owner Name", ownerImage: nil, files: [file])

        gist.isFavorite
            .asDriver()
            .drive(isFavorite)
            .disposed(by: disposeBag)

        // When
        scheduler.createColdObservable([
            .next(10, true),
            .next(20, false)
        ])
            .bind(to: gist.favorite)
            .disposed(by: disposeBag)

        scheduler.start()

        // Then
        XCTAssertEqual(isFavorite.events, [
            .next(0, false),
            .next(10, true),
            .next(20, false)
        ])
    }

}
