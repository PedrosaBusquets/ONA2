import SwiftUI

struct RootView: View {
    @EnvironmentObject var appVM: AppViewModel
    
    var body: some View {
        Group {
            if appVM.showStartResumePrompt {
                StopConfigView(showResumeBanner: true)
            } else {
                switch appVM.mode {
                case .stop:
                    StopConfigView(showResumeBanner: false)
                case .start:
                    StartTouchpadView()
                }
            }
        }
    }
}