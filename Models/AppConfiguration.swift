import Foundation

struct AppConfiguration: Codable {
    var lastMode: AppMode = .stop
    
    // Camera
    var selectedCameraId: String?
    var flip: Bool = false
    var mirror: Bool = false
    
    // Glasses
    var selectedGlassesId: String?
    
    // Outline color
    var selectedOutlineColorId: String?
    
    // Geometric transform (two‑finger gestures)
    var zoom: Double = 1.2          // default slight zoom
    var aspectHeightRatio: Double = 1.0
    var panX: Double = 0.0          // -1...+1 or %
    var panY: Double = 0.0
    var rotationDegrees: Double = 0.0
    
    // Image parameters (one‑finger loop menu)
    var brightness: Double = 0.0    // -1...+1
    var contrast: Double = 1.2      // 0...4
    var detectionThreshold: Double = 0.4 // 0...1
    var outlineWidth: Double = 2.0  // 1...10
}