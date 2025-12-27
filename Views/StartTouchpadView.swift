import SwiftUI

struct StartTouchpadView: View {
    @EnvironmentObject var appVM: AppViewModel
    @StateObject private var gestureController = GestureController()
    
    // We keep last 2‑finger state for delta calculations
    @State private var twoFingerStart: TwoFingerState?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("START")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    .padding()
                
                if gestureController.isMenuActive {
                    menuOverlay()
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            
            TouchSurfaceView(
                onOneFingerBegan: { state in
                    gestureController.isMenuActive = true
                    gestureController.oneFingerStart = state.start
                },
                onOneFingerChanged: { state in
                    handleOneFingerChanged(state: state)
                },
                onOneFingerEnded: { state in
                    handleOneFingerEnded(state: state)
                },
                onTwoFingerBegan: { state in
                    twoFingerStart = state
                },
                onTwoFingerChanged: { state in
                    handleTwoFingerChanged(state: state)
                },
                onTwoFingerEnded: { _ in
                    twoFingerStart = nil
                },
                onTouchesEnded: {
                    // all touches ended; menu can auto‑hide after timeout
                }
            )
        }
        .onDisappear {
            // Config is auto‑persisted by AppViewModel
        }
    }
    
    // MARK: - Menu Overlay (for feedback)
    
    @ViewBuilder
    private func menuOverlay() -> some View {
        let outlineColor = appVM.selectedOutlineColor?.color ?? .red
        
        HStack(spacing: 24) {
            ForEach(MenuOption.allCases, id: \.self) { option in
                VStack {
                    Image(systemName: option.iconName)
                        .font(.title2)
                        .foregroundColor(option == gestureController.currentMenu ? outlineColor : .gray)
                    Text(option.label)
                        .font(.caption)
                        .foregroundColor(option == gestureController.currentMenu ? outlineColor : .gray)
                }
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
    
    // MARK: - One‑finger logic (loop menu)
    
    private func handleOneFingerChanged(state: OneFingerState) {
        guard let start = gestureController.oneFingerStart else {
            gestureController.oneFingerStart = state.start
            return
        }
        
        gestureController.isMenuActive = true
        
        let dx = state.current.x - start.x
        let dy = state.current.y - start.y
        
        let horizontalThreshold: CGFloat = 1.0
        
        if dx > horizontalThreshold {
            gestureController.nextMenu()
            gestureController.oneFingerStart = state.current
        } else if dx < -horizontalThreshold {
            gestureController.previousMenu()
            gestureController.oneFingerStart = state.current
        }
        
        // Vertical swipe -> value change
        let valueSensitivity = 0.01
        let deltaValue = Double(dy) * valueSensitivity // down increases
        
        switch gestureController.currentMenu {
        case .brightness:
            appVM.config.brightness = max(-1.0, min(1.0, appVM.config.brightness + deltaValue))
        case .contrast:
            appVM.config.contrast = max(0.1, min(4.0, appVM.config.contrast + deltaValue))
        case .threshold:
            appVM.config.detectionThreshold = max(0.0, min(1.0, appVM.config.detectionThreshold + deltaValue))
        case .outlineWidth:
            appVM.config.outlineWidth = max(1.0, min(10.0, appVM.config.outlineWidth + deltaValue * 10.0))
        case .stop:
            break
        }
    }
    
    private func handleOneFingerEnded(state: OneFingerState) {
        if gestureController.currentMenu == .stop {
            appVM.goToStopMode()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                gestureController.isMenuActive = false
            }
        }
        gestureController.resetOneFinger()
    }
    
    // MARK: - Two‑finger logic (zoom, pan, rotate, height)
    
    private func handleTwoFingerChanged(state: TwoFingerState) {
        guard let start = twoFingerStart else {
            twoFingerStart = state
            return
        }
        
        let f1Start = start.finger1Start
        let f2Start = start.finger2Start
        let f1Cur = state.finger1Current
        let f2Cur = state.finger2Current
        
        let dx0 = abs(f2Start.x - f1Start.x)
        let dx1 = abs(f2Cur.x - f1Cur.x)
        
        let dy0 = abs(f2Start.y - f1Start.y)
        let dy1 = abs(f2Cur.y - f1Cur.y)
        
        let c0 = NormalizedPoint(
            x: (f1Start.x + f2Start.x) / 2.0,
            y: (f1Start.y + f2Start.y) / 2.0
        )
        let c1 = NormalizedPoint(
            x: (f1Cur.x + f2Cur.x) / 2.0,
            y: (f1Cur.y + f2Cur.y) / 2.0
        )
        
        let deltaX = c1.x - c0.x
        let deltaY = c1.y - c0.y
        
        // 1) Zoom: horizontal spread
        let zoomSensitivity = 0.01
        let zoomDelta = (dx1 - dx0) * zoomSensitivity
        appVM.config.zoom = max(0.1, min(5.0, appVM.config.zoom + Double(zoomDelta)))
        
        // 2) Height ratio: vertical spread
        let aspectSensitivity = 0.01
        let aspectDelta = (dy1 - dy0) * aspectSensitivity
        appVM.config.aspectHeightRatio = max(0.5, min(2.0, appVM.config.aspectHeightRatio + Double(aspectDelta)))
        
        // 3) Pan
        let panSensitivity = 0.01
        appVM.config.panX += Double(deltaX) * Double(panSensitivity)
        appVM.config.panY += Double(deltaY) * Double(panSensitivity)
        
        // 4) Rotation
        let v0 = CGPoint(x: f2Start.x - f1Start.x, y: f2Start.y - f1Start.y)
        let v1 = CGPoint(x: f2Cur.x - f1Cur.x, y: f2Cur.y - f1Cur.y)
        let angle0 = atan2(v0.y, v0.x)
        let angle1 = atan2(v1.y, v1.x)
        let deltaAngleRad = angle1 - angle0
        let deltaAngleDeg = deltaAngleRad * 180.0 / .pi
        
        let rotationSensitivity = 0.1
        appVM.config.rotationDegrees += Double(deltaAngleDeg) * Double(rotationSensitivity)
    }
}