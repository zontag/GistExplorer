import Foundation
import RealmSwift

final class FileEntity: EmbeddedObject {
    @objc dynamic var name: String?
    @objc dynamic var type: String?
    @objc dynamic var url: String?
    @objc dynamic var size: Int = 0
    @objc dynamic var language: String?
}
