import Foundation

extension AppViewModel {
    func updatePipelineFromConfig() {
        let outlineCIColor: CIColor? = {
            if let opt = selectedOutlineColor,
               let c = opt.color {
                // Convert SwiftUI Color -> UIColor -> CIColor
                let ui = UIColor(c)
                return CIColor(color: ui)
            } else {
                return nil
            }
        }()
        
        let cfg = PipelineConfig(
            zoom: CGFloat(config.zoom),
            aspectHeightRatio: CGFloat(config.aspectHeightRatio),
            panX: CGFloat(config.panX),
            panY: CGFloat(config.panY),
            rotationDegrees: CGFloat(config.rotationDegrees),
            brightness: CGFloat(config.brightness),
            contrast: CGFloat(config.contrast),
            detectionThreshold: CGFloat(config.detectionThreshold),
            outlineWidth: CGFloat(config.outlineWidth),
            outlineColor: outlineCIColor
        )
        
        CameraManager.shared.pipeline.config = cfg
    }
}