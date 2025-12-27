import CoreGraphics

/// Normalized coordinates (0–100 in both axes)
struct NormalizedPoint {
    var x: CGFloat
    var y: CGFloat
}

struct TwoFingerState {
    var finger1Start: NormalizedPoint
    var finger2Start: NormalizedPoint
    var finger1Current: NormalizedPoint
    var finger2Current: NormalizedPoint
}

struct OneFingerState {
    var start: NormalizedPoint
    var current: NormalizedPoint
}