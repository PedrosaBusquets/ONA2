import SwiftUI

struct TouchSurfaceView: UIViewRepresentable {
    class Coordinator: NSObject {
        var parent: TouchSurfaceView
        
        // Active touches
        var touches: [UITouch: NormalizedPoint] = [:]
        
        init(parent: TouchSurfaceView) {
            self.parent = parent
        }
        
        private func normalizedPoint(from touch: UITouch, in view: UIView) -> NormalizedPoint {
            let p = touch.location(in: view)
            let w = max(view.bounds.width, 1)
            let h = max(view.bounds.height, 1)
            let nx = (p.x / w) * 100.0
            let ny = (p.y / h) * 100.0
            return NormalizedPoint(x: nx, y: ny)
        }
        
        func processTouches(_ touchesSet: Set<UITouch>, in view: UIView) {
            // Update or add touches
            for t in touchesSet {
                let n = normalizedPoint(from: t, in: view)
                touches[t] = n
            }
            
            let active = Array(touches.values)
            
            switch active.count {
            case 1:
                if let p = active.first {
                    parent.onOneFingerChanged?(OneFingerState(start: p, current: p))
                }
            case 2:
                let p1 = active[0]
                let p2 = active[1]
                let state = TwoFingerState(
                    finger1Start: p1,
                    finger2Start: p2,
                    finger1Current: p1,
                    finger2Current: p2
                )
                parent.onTwoFingerChanged?(state)
            default:
                break
            }
        }
        
        func endTouches(_ touchesSet: Set<UITouch>) {
            for t in touchesSet {
                touches.removeValue(forKey: t)
            }
            
            if touches.isEmpty {
                parent.onTouchesEnded?()
            }
        }
    }
    
    var onOneFingerBegan: ((OneFingerState) -> Void)?
    var onOneFingerChanged: ((OneFingerState) -> Void)?
    var onOneFingerEnded: ((OneFingerState) -> Void)?
    
    var onTwoFingerBegan: ((TwoFingerState) -> Void)?
    var onTwoFingerChanged: ((TwoFingerState) -> Void)?
    var onTwoFingerEnded: ((TwoFingerState) -> Void)?
    
    var onTouchesEnded: (() -> Void)?
    
    func makeUIView(context: Context) -> UIView {
        let view = TouchSurfaceUIView()
        view.backgroundColor = .clear
        view.coordinator = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

/// Internal UIView that forwards touch events to the coordinator
final class TouchSurfaceUIView: UIView {
    weak var coordinator: TouchSurfaceView.Coordinator?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let coordinator = coordinator else { return }
        
        coordinator.processTouches(touches, in: self)
        
        let active = Array(coordinator.touches.values)
        if active.count == 1, let p = active.first {
            coordinator.parent.onOneFingerBegan?(OneFingerState(start: p, current: p))
        } else if active.count == 2 {
            let p1 = active[0]
            let p2 = active[1]
            let state = TwoFingerState(
                finger1Start: p1,
                finger2Start: p2,
                finger1Current: p1,
                finger2Current: p2
            )
            coordinator.parent.onTwoFingerBegan?(state)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        coordinator?.processTouches(touches, in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let coordinator = coordinator else { return }
        
        // Before removing them, capture one/two finger end state if needed.
        let active = Array(coordinator.touches.values)
        if active.count == 1, let p = active.first {
            coordinator.parent.onOneFingerEnded?(OneFingerState(start: p, current: p))
        } else if active.count == 2 {
            let p1 = active[0]
            let p2 = active[1]
            let state = TwoFingerState(
                finger1Start: p1,
                finger2Start: p2,
                finger1Current: p1,
                finger2Current: p2
            )
            coordinator.parent.onTwoFingerEnded?(state)
        }
        
        coordinator.endTouches(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        coordinator?.endTouches(touches)
    }
}