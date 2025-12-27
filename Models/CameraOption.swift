import Foundation

struct CameraOption: Identifiable, Codable, Equatable {
    let id: String          // e.g. "backWide", "front"
    var name: String        // UI label
    var isFront: Bool
}