import Foundation
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

@MainActor
final class CameraManager: NSObject, ObservableObject {
    static let shared = CameraManager()
    
    @Published var isRunning: Bool = false
    
    // For debugging / internal preview
    @Published var previewImage: Image?
    
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "ONA2.CameraSessionQueue")
    
    private var videoOutput = AVCaptureVideoDataOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    private var ciContext = CIContext()
    
    // Configuration
    var selectedCameraId: String = "backWide" {
        didSet { configureSession() }
    }
    var flip: Bool = false {
        didSet { /* can adjust orientation if needed */ }
    }
    var mirror: Bool = false
    
    // Image processing pipeline
    let pipeline = ImageProcessingPipeline()
    
    private override init() {
        super.init()
        configureSession()
    }
    
    func startRunning() {
        guard !isRunning else { return }
        isRunning = true
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopRunning() {
        guard isRunning else { return }
        isRunning = false
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    private func configureSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            
            // Remove existing input
            if let input = self.videoDeviceInput {
                self.session.removeInput(input)
            }
            
            // Select device
            let position: AVCaptureDevice.Position = (self.selectedCameraId == "front") ? .front : .back
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: position) else {
                print("No camera device for position \(position)")
                self.session.commitConfiguration()
                return
            }
            
            do {
                let newInput = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                    self.videoDeviceInput = newInput
                } else {
                    print("Cannot add camera input")
                }
            } catch {
                print("Error creating camera input: \(error)")
            }
            
            // Configure output
            if self.session.outputs.isEmpty {
                self.videoOutput = AVCaptureVideoDataOutput()
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
                if self.session.canAddOutput(self.videoOutput) {
                    self.session.addOutput(self.videoOutput)
                }
            }
            
            // Set video orientation if needed
            if let connection = self.videoOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .landscapeRight
                }
                connection.isVideoMirrored = (position == .front) || self.mirror
            }
            
            self.session.commitConfiguration()
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard isRunning,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Apply processing pipeline
        let processed = pipeline.process(image: image)
        
        // For now, we create a SwiftUI Image for preview/debug
        if let cgImage = ciContext.createCGImage(processed, from: processed.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            let swiftImage = Image(uiImage: uiImage)
            DispatchQueue.main.async {
                self.previewImage = swiftImage
            }
        }
        
        // TODO: In the future, render `processed` into the external display view
        // via Metal or a CI-backed layer, not just SwiftUI Image.
    }
}