import Foundation

extension String {
    var searchTokens: [String] {
        self.components(separatedBy: CharacterSet.alphanumerics.inverted).map { $0.lowercased() }
    }
}
