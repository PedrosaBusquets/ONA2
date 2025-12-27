import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct PipelineConfig {
    // Geometric
    var zoom: CGFloat = 1.2
    var aspectHeightRatio: CGFloat = 1.0
    var panX: CGFloat = 0.0   // in normalized units (approx -1...1)
    var panY: CGFloat = 0.0
    var rotationDegrees: CGFloat = 0.0
    
    // Image parameters
    var brightness: CGFloat = 0.0  // -1...+1
    var contrast: CGFloat = 1.2    // 0...4
    var detectionThreshold: CGFloat = 0.4 // 0...1
    var outlineWidth: CGFloat = 2.0
    
    // Outline color; nil means transparent/disabled
    var outlineColor: CIColor? = CIColor(red: 1, green: 0, blue: 0, alpha: 1)
}

final class ImageProcessingPipeline {
    private let context = CIContext()
    
    // We keep a config we can update externally
    var config = PipelineConfig()
    
    func process(image: CIImage) -> CIImage {
        var output = image
        
        // 1. Geometric transform (zoom, pan, rotate, aspect)
        output = applyTransform(to: output)
        
        // 2. Basic brightness/contrast
        output = applyColorControls(to: output)
        
        // 3. Edge detection + threshold
        let edges = detectEdges(on: output)
        
        // 4. Outline overlay
        output = overlayEdges(edges, on: output)
        
        return output
    }
    
    // MARK: - Transform
    
    private func applyTransform(to image: CIImage) -> CIImage {
        let w = image.extent.width
        let h = image.extent.height
        
        // Center
        let centerX = image.extent.midX
        let centerY = image.extent.midY
        
        // Build transform: translate to origin -> scale -> aspect -> rotate -> translate back -> pan
        var transform = CGAffineTransform.identity
        
        // Translate to origin
        transform = transform
            .translatedBy(x: -centerX, y: -centerY)
        
        // Zoom
        transform = transform.scaledBy(x: config.zoom, y: config.zoom * config.aspectHeightRatio)
        
        // Rotate
        let radians = config.rotationDegrees * .pi / 180.0
        transform = transform.rotated(by: radians)
        
        // Translate back
        transform = transform.translatedBy(x: centerX, y: centerY)
        
        // Pan (in percentage of width/height)
        let panScale: CGFloat = 0.01
        let panX = config.panX * w * panScale
        let panY = config.panY * h * panScale
        
        transform = transform.translatedBy(x: panX, y: panY)
        
        return image.transformed(by: transform)
    }
    
    // MARK: - Color controls
    
    private func applyColorControls(to image: CIImage) -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.brightness = Float(config.brightness)
        filter.contrast = Float(config.contrast)
        // Keep saturation = 1 for now
        filter.saturation = 1.0
        return filter.outputImage ?? image
    }
    
    // MARK: - Edge detection
    
    private func detectEdges(on image: CIImage) -> CIImage {
        // Simple edge detection with CIEdges
        let edgesFilter = CIFilter.edges()
        edgesFilter.inputImage = image
        edgesFilter.intensity = 1.0
        
        guard var edges = edgesFilter.outputImage else {
            return image
        }
        
        // Convert to grayscale then apply threshold
        let grayFilter = CIFilter.photoEffectNoir()
        grayFilter.inputImage = edges
        if let gray = grayFilter.outputImage {
            edges = gray
        }
        
        // Threshold using a simple color matrix trick
        // We approximate threshold by boosting contrast strongly around detectionThreshold.
        let threshold = config.detectionThreshold
        
        let t = threshold
        let s: CGFloat = 10.0 // "sharpness" of threshold
        // Output = clamp((input - t) * s + 0.5, 0,1)
        let thresholdFilter = CIFilter.colorMatrix()
        thresholdFilter.inputImage = edges
        
        thresholdFilter.rVector = CIVector(x: s, y: 0, z: 0, w: 0)
        thresholdFilter.gVector = CIVector(x: 0, y: s, z: 0, w: 0)
        thresholdFilter.bVector = CIVector(x: 0, y: 0, z: s, w: 0)
        thresholdFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        
        let bias = Float(0.5 - s * t)
        thresholdFilter.biasVector = CIVector(x: bias, y: bias, z: bias, w: 0)
        
        if let thresholded = thresholdFilter.outputImage {
            edges = thresholded
        }
        
        return edges
    }
    
    // MARK: - Overlay edges
    
    private func overlayEdges(_ edges: CIImage, on base: CIImage) -> CIImage {
        guard let outlineColor = config.outlineColor else {
            // Outline disabled
            return base
        }
        
        // We want a monochrome mask of edges
        let alphaMaskFilter = CIFilter.colorMatrix()
        alphaMaskFilter.inputImage = edges
        alphaMaskFilter.rVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        alphaMaskFilter.gVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        alphaMaskFilter.bVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        alphaMaskFilter.aVector = CIVector(x: 1, y: 1, z: 1, w: 0) // use luminance as alpha
        alphaMaskFilter.biasVector = CIVector(x: 0, y: 0, z: 0, w: 0)
        
        guard var alphaMask = alphaMaskFilter.outputImage else {
            return base
        }
        
        // Simulate outline width with a small blur / dilation
        let radius = config.outlineWidth
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = alphaMask
        blurFilter.radius = Float(radius)
        if let blurred = blurFilter.outputImage {
            alphaMask = blurred.clamped(to: base.extent)
        }
        
        // Create a solid color image to be used with the mask
        let colorImage = CIImage(color: outlineColor).cropped(to: base.extent)
        
        // Composite: overlay outline color where mask is non-zero
        let maskedOutline = colorImage.applyingFilter(
            "CIBlendWithAlphaMask",
            parameters: [
                kCIInputMaskImageKey: alphaMask
            ]
        )
        
        // Finally, composite over base image
        let result = maskedOutline.composited(over: base)
        return result
    }
}