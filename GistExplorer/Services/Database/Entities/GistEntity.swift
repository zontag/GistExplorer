import Foundation
import RealmSwift

final class GistEntity: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var ownerName: String?
    @objc dynamic var ownerImage: String?
    let files = List<FileEntity>()

    override static func primaryKey() -> String? {
        return "id"
    }
}
