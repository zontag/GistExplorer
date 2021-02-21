import Foundation
import CoreData

enum Map {
    static func mapGistFileToEntity(_ file: Gist.File) -> FileEntity {
        let entity = FileEntity()
        entity.language = file.language.value
        entity.name = file.name.value
        entity.size = file.size.value ?? 0
        entity.type = file.type.value
        entity.url = file.url.value?.absoluteString
        return entity
    }

    static func mapGistToEnity(_ gist: Gist) -> GistEntity {
        let entity = GistEntity()
        entity.id = gist.id.value
        entity.ownerImage = gist.ownerImage.value?.absoluteString
        entity.ownerName = gist.ownerName.value
        entity.files.append(objectsIn: gist.files.value?.map(Map.mapGistFileToEntity) ?? [])
        return entity
    }

    static func mapSelf<T>(_ input: T) -> T { input }

    static func mapResponseToGist(injector: Injectable) -> (GistResponse) -> Gist {
        return { (response: GistResponse) in
            Gist(injector: injector, id: response.id,
                 ownerName: response.owner?.login ?? "",
                 ownerImage: URL(string: response.owner?.avatarURL ?? ""),
                 files: response.files?.values.map(Map.mapResponseToGistFile))
        }
    }

    static func mapResponseToGistFile(_ response: FileResponse) -> Gist.File {
        Gist.File(name: response.fileName,
                  type: response.type,
                  url: URL(string: response.rawURL ?? ""),
                  size: response.size,
                  language: response.language)
    }

    static func mapEntityToGist(_ injector: Injectable) -> (GistEntity) -> Gist {
        return { (entity: GistEntity) -> Gist in
            Gist(injector: injector,
                 id: entity.id,
                 ownerName: entity.ownerName,
                 ownerImage: URL(string: entity.ownerImage ?? ""),
                 files: entity.files.map(Map.mapEntityToFile))
        }
    }

    static func mapEntityToFile(_ entity: FileEntity) -> Gist.File {
        Gist.File(name: entity.name,
                  type: entity.type,
                  url: URL(string: entity.url ?? ""),
                  size: entity.size,
                  language: entity.language)
    }
 }
