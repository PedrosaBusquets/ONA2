import SwiftUI

struct DebugPreviewView: View {
    @ObservedObject var cameraManager = CameraManager.shared
    
    var body: some View {
        Group {
            if let img = cameraManager.previewImage {
                img
                    .resizable()
                    .scaledToFit()
            } else {
                Text("No preview")
                    .foregroundColor(.gray)
            }
        }
    }
}