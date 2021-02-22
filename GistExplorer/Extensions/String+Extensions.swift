import Foundation

extension String {
    var searchTokens: [String] {
        self.components(separatedBy: CharacterSet.whitespacesAndNewlines.union(CharacterSet.alphanumerics.inverted)).map { $0.lowercased() }
    }
}
