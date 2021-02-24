import XCTest
import RxTest
import RxRelay
import RxBlocking
import RxSwift
@testable import GistExplorer

// swiftlint:disable overridden_super_call implicitly_unwrapped_optional
class GistListViewModelTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var viewModel: GistListViewModel!
    let injector = Injector()

    let favoriteDatabaseMock: FavoriteDatabase = FavoriteDatabaseMock()
    let gistPagedListModel = GistPagedListModelMock()

    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        injector.register(gistPagedListModel as GistPagedListModel)
        injector.register(favoriteDatabaseMock as FavoriteDatabase)
        gistPagedListModel.error = nil
        gistPagedListModel.gistList = []
        viewModel = GistListViewModel(injector: injector)
        viewModel.input.filterText.accept("")
        viewModel.input.showFavorites.accept(())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGistListViewModel_FirstLoad() throws {
        // Given
        let gist1 = Gist(id: "1", ownerName: "Owner name 1", ownerImage: nil, files: [])
        let gist2 = Gist(id: "2", ownerName: "Owner name 2", ownerImage: nil, files: [])
        let items = [gist1, gist2]

        gistPagedListModel.gistList.append(contentsOf: items)

        let list = scheduler.createObserver([Gist].self)

        viewModel.output.gistList
            .drive(list)
            .disposed(by: disposeBag)

        // When
        scheduler.createColdObservable([.next(10, ())])
            .bind(to: viewModel.input.load)
            .disposed(by: disposeBag)

        scheduler.start()

        // Then
        XCTAssertEqual(list.events, [
            .next(0, []),
            .next(10, items)
        ])
    }

    func testGistListViewModel_PrefetchItemsAt() throws {
        // Given
        let gist1 = Gist(id: "1", ownerName: "Owner name 1", ownerImage: nil, files: [])
        let gist2 = Gist(id: "2", ownerName: "Owner name 2", ownerImage: nil, files: [])
        let gist3 = Gist(id: "3", ownerName: "Owner name 3", ownerImage: nil, files: [])
        let items = [gist1, gist2, gist3]

        // Prepare for first load
        gistPagedListModel.gistList.append(contentsOf: items)
        // Force first load
        viewModel.input.load.accept(())
        // Prepare for prefetch
        gistPagedListModel.gistList.append(contentsOf: items)

        let list = scheduler.createObserver([Gist].self)

        viewModel.output.gistList
            .drive(list)
            .disposed(by: disposeBag)

        // When
        scheduler.createColdObservable([
            .next(10, items.count - 2), // Should not call load
            .next(20, items.count), // Should not call load
            .next(30, items.count - 1)
        ])
            .bind(to: viewModel.input.prefetchItemsAt)
            .disposed(by: disposeBag)

        scheduler.start()

        // Then
        XCTAssertEqual(list.events, [
            .next(0, items),
            .next(30, items + items)
        ])
    }

    func testGistListViewModel_SelectGist() throws {
        // Given
        let gist1 = Gist(id: "1", ownerName: "Owner name 1", ownerImage: nil, files: [])
        let selectedGist = scheduler.createObserver(Gist.self)

        viewModel.output.selectedGist
            .emit(to: selectedGist)
            .disposed(by: disposeBag)

        // When
        scheduler.createColdObservable([
            .next(10, gist1)
        ])
        .bind(to: viewModel.input.selectedGist)
        .disposed(by: disposeBag)

        scheduler.start()

        // Then
        XCTAssertEqual(selectedGist.events, [
            .next(10, gist1)
        ])
    }

    func testGistListViewModel_Filter() throws {
        // Given
        let gist1 = Gist(id: "1", ownerName: "Owner name 1", ownerImage: nil, files: [])
        let gist2 = Gist(id: "2", ownerName: "Owner name 2", ownerImage: nil, files: [])
        let gist3 = Gist(id: "3", ownerName: "Owner name 3", ownerImage: nil, files: [])
        let items = [gist1, gist2, gist3]

        // Prepare for first load
        gistPagedListModel.gistList.append(contentsOf: items)
        // Force first load
        viewModel.input.load.accept(())

        let listObserver = scheduler.createObserver([Gist].self)

        viewModel.output.gistList
            .drive(listObserver)
            .disposed(by: disposeBag)

        // When
        scheduler.createColdObservable([
            .next(10, "2")
        ])
        .bind(to: viewModel.input.filterText)
        .disposed(by: disposeBag)

        scheduler.start()

        // Then
        XCTAssertEqual(listObserver.events, [
            .next(0, items),
            .next(10, [gist2])
        ])
    }

    func testGistListViewModel_ShowFavorites() throws {
        // Given
        let isShowingFavorites = scheduler.createObserver(Void.self)
        viewModel.output.showFavorites
            .asDriver(onErrorJustReturn: ())
            .drive(isShowingFavorites)
            .disposed(by: disposeBag)

        // When
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: viewModel.input.showFavorites)
        .disposed(by: disposeBag)

        scheduler.start()

        // Then
        XCTAssertEqual(isShowingFavorites.events.count, 1)
    }
}
