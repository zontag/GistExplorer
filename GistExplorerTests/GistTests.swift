import XCTest
import RxTest
import RxRelay
import RxBlocking
import RxSwift
@testable import GistExplorer

// swiftlint:disable overridden_super_call implicitly_unwrapped_optional
class GistTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    let injector = Injector()

    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        injector.register(FavoritesGistModelMock() as FavoritesGistModel)
    }

    override func tearDownWithError() throws { }

    func testGist_PropertiesAttribution() throws {
        // Given
        let fileName = "File name"
        let fileType = "File Type"
        let fileURL = URL(string: "https://github.com")!
        let fileSize = 100
        let fileLaguage = "Swift"

        let gistID = "1234"
        let gistOwnerName = "Owner Name"
        let gistOwnerImage = URL(string: "https://github.com")

        // When
        let file = Gist.File(name: fileName, type: fileType, url: fileURL, size: fileSize, language: fileLaguage)
        let gist = Gist(injector: injector, id: gistID, ownerName: gistOwnerName, ownerImage: gistOwnerImage, files: [file])

        // Then
        XCTAssertEqual(gist.files.value?.first, file)
        XCTAssertEqual(gist.ownerName.value, gistOwnerName)
        XCTAssertEqual(gist.ownerImage.value, gistOwnerImage)
        XCTAssertEqual(gist.id.value, gistID)
    }

    func testGist_FavoriteBehavior() throws {

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
