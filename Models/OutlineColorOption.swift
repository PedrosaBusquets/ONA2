import SwiftUI

struct OutlineColorOption: Identifiable, Codable, Equatable {
    let id: String                  // e.g. "red", "transparent"
    var name: String                // e.g. "Red", "Transparent"
    // Stored color is not Codable, but we persist via id
    var color: Color? {
        switch id {
        case "transparent":
            return nil
        case "red":
            return .red
        case "green":
            return .green
        case "cyan":
            return .cyan
        default:
            return .white
        }
    }
}