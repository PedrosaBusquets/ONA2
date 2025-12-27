import Foundation

enum GlassesConnectionType: String, Codable {
    case airPlay
    case cable
    case bluetooth
    case wifi
}

struct GlassesProfile: Identifiable, Codable, Equatable {
    let id: String          // e.g. "rokidMaxAirPlay"
    var name: String        // e.g. "ROKID Max (AirPlay)"
    var connectionType: GlassesConnectionType
    
    // Viewing window (informational focus)
    var viewWidthPercent: Double   // 0–100
    var viewHeightPercent: Double  // 0–100
    var offsetXPercent: Double     // 0–100
    var offsetYPercent: Double     // 0–100
}