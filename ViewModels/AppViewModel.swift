import SwiftUI

final class AppViewModel: ObservableObject {
    @Published var mode: AppMode
    @Published var showStartResumePrompt: Bool = false
    
    @Published var availableCameras: [CameraOption]
    @Published var availableGlasses: [GlassesProfile]
    @Published var outlineColors: [OutlineColorOption]
    
    @Published var config: AppConfiguration {
        didSet { settingsManager.configuration = config }
    }
    
    private let settingsManager: SettingsManager
    
    init(settingsManager: SettingsManager = SettingsManager()) {
        self.settingsManager = settingsManager
        self.config = settingsManager.configuration
        self.mode = config.lastMode
        
        self.availableCameras = [
            CameraOption(id: "backWide", name: "Back Wide", isFront: false),
            CameraOption(id: "front", name: "Front", isFront: true)
        ]
        
        self.availableGlasses = [
            GlassesProfile(
                id: "rokidMaxAirPlay",
                name: "ROKID Max (AirPlay)",
                connectionType: .airPlay,
                viewWidthPercent: 80,
                viewHeightPercent: 80,
                offsetXPercent: 10,
                offsetYPercent: 10
            )
            // Add more glasses profiles as needed
        ]
        
        self.outlineColors = [
            OutlineColorOption(id: "transparent", name: "Transparent (Disabled)"),
            OutlineColorOption(id: "red", name: "Red"),
            OutlineColorOption(id: "green", name: "Green"),
            OutlineColorOption(id: "cyan", name: "Cyan")
        ]
        
        ensureDefaults()
        
        // Behavior 2: On subsequent launches, if last mode was START,
        // open STOP with "Resume START" prompt/banner.
        if settingsManager.configuration.lastMode == .start {
            self.mode = .stop
            self.showStartResumePrompt = true
        }
    }
    
    private func ensureDefaults() {
        if config.selectedCameraId == nil {
            config.selectedCameraId = availableCameras.first?.id
        }
        if config.selectedGlassesId == nil {
            config.selectedGlassesId = availableGlasses.first?.id
        }
        if config.selectedOutlineColorId == nil {
            config.selectedOutlineColorId = outlineColors.first?.id
        }
    }
    
    // MARK: - Mode transitions
    
    func goToStartMode() {
        showStartResumePrompt = false
        mode = .start
        config.lastMode = .start
    }
    
    func goToStopMode() {
        mode = .stop
        config.lastMode = .stop
    }
    
    // MARK: - Helpers
    
    var selectedCamera: CameraOption? {
        availableCameras.first { $0.id == config.selectedCameraId }
    }
    
    var selectedGlasses: GlassesProfile? {
        availableGlasses.first { $0.id == config.selectedGlassesId }
    }
    
    var selectedOutlineColor: OutlineColorOption? {
        outlineColors.first { $0.id == config.selectedOutlineColorId }
    }
}