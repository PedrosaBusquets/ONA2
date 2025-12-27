import SwiftUI

struct StopConfigView: View {
    @EnvironmentObject var appVM: AppViewModel
    let showResumeBanner: Bool
    
    init(showResumeBanner: Bool = false) {
        self.showResumeBanner = showResumeBanner
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showResumeBanner {
                    resumeBanner
                }
                
                Form {
                    cameraSection
                    glassesSection
                    outlineColorSection
                }
                
                startButton
            }
            .navigationTitle("ONAMCORDA – STOP")
        }
    }
    
    private var resumeBanner: some View {
        HStack {
            Text("Last session was in START mode.")
                .font(.footnote)
            Spacer()
            Button("Resume START") {
                appVM.goToStartMode()
            }
            .font(.footnote.bold())
        }
        .padding(8)
        .background(Color.yellow.opacity(0.2))
    }
    
    private var cameraSection: some View {
        Section("Camera") {
            Picker("Camera", selection: Binding(
                get: { appVM.config.selectedCameraId ?? "" },
                set: { appVM.config.selectedCameraId = $0 }
            )) {
                ForEach(appVM.availableCameras) { camera in
                    Text(camera.name).tag(camera.id)
                }
            }
            
            Toggle("Flip", isOn: $appVM.config.flip)
            Toggle("Mirror", isOn: $appVM.config.mirror)
        }
    }
    
    private var glassesSection: some View {
        Section("Glasses") {
            Picker("Device", selection: Binding(
                get: { appVM.config.selectedGlassesId ?? "" },
                set: { appVM.config.selectedGlassesId = $0 }
            )) {
                ForEach(appVM.availableGlasses) { glasses in
                    Text("\(glasses.name) [\(glasses.connectionType.rawValue.capitalized)]")
                        .tag(glasses.id)
                }
            }
            
            if let g = appVM.selectedGlasses {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Viewing Area (Informational)").font(.footnote).bold()
                    Text("Width: \(Int(g.viewWidthPercent))%")
                    Text("Height: \(Int(g.viewHeightPercent))%")
                    Text("Offset X: \(Int(g.offsetXPercent))%")
                    Text("Offset Y: \(Int(g.offsetYPercent))%")
                }
            }
        }
    }
    
    private var outlineColorSection: some View {
        Section("Outline Color") {
            Picker("Outline Color", selection: Binding(
                get: { appVM.config.selectedOutlineColorId ?? "" },
                set: { appVM.config.selectedOutlineColorId = $0 }
            )) {
                ForEach(appVM.outlineColors) { option in
                    HStack {
                        if let c = option.color {
                            Circle()
                                .fill(c)
                                .frame(width: 16, height: 16)
                        } else {
                            Text("Ø")
                                .font(.caption)
                                .frame(width: 16, height: 16)
                        }
                        Text(option.name)
                    }
                    .tag(option.id)
                }
            }
        }
    }
    
    private var startButton: some View {
        Button(action: {
            appVM.goToStartMode()
        }) {
            Text("START")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
}