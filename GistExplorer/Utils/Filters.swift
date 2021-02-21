import Foundation

enum Filter {

    // swiftlint:disable reduce_boolean
    static func filterGistListByOwnerName(_ list: [Gist], _ filter: String) -> [Gist] {
        if filter.isEmpty { return list }
        let tokens = filter.searchTokens
        return list.filter { (gist) -> Bool in
            guard let name = gist.ownerName.value?.lowercased() else { return false }
            return tokens.reduce(false) { (result, text) -> Bool in name.contains(text) || result }
        }
    }
}
