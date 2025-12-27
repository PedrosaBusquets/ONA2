import UIKit
import SwiftUI

final class DisplayManager: ObservableObject {
    static let shared = DisplayManager()
    
    @Published var externalScreen: UIScreen?
    
    private var externalWindow: UIWindow?
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensDidChange),
            name: UIScreen.didConnectNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensDidChange),
            name: UIScreen.didDisconnectNotification,
            object: nil
        )
        
        screensDidChange()
    }
    
    @objc private func screensDidChange() {
        let screens = UIScreen.screens
        externalScreen = screens.count > 1 ? screens[1] : nil
        configureExternalWindowIfNeeded()
    }
    
    private func configureExternalWindowIfNeeded() {
        guard let screen = externalScreen else {
            externalWindow?.isHidden = true
            externalWindow = nil
            return
        }
        
        if externalWindow == nil {
            let window = UIWindow(frame: screen.bounds)
            window.screen = screen
            let controller = UIHostingController(rootView: ExternalDisplayPlaceholderView())
            window.rootViewController = controller
            window.isHidden = false
            externalWindow = window
        } else {
            externalWindow?.screen = screen
            externalWindow?.frame = screen.bounds
            externalWindow?.isHidden = false
        }
    }
}

struct ExternalDisplayPlaceholderView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("ONAMCORDA – Glasses View")
                .foregroundColor(.white)
        }
    }
}