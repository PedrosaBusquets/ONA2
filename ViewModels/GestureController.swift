import Foundation

enum MenuOption: CaseIterable {
    case brightness
    case contrast
    case threshold
    case outlineWidth
    case stop
    
    var iconName: String {
        switch self {
        case .brightness:  return "lightbulb"
        case .contrast:    return "sun.max"
        case .threshold:   return "triangle"
        case .outlineWidth:return "pencil"
        case .stop:        return "gear"
        }
    }
    
    var label: String {
        switch self {
        case .brightness:  return "Brightness"
        case .contrast:    return "Contrast"
        case .threshold:   return "Threshold"
        case .outlineWidth:return "Outline Width"
        case .stop:        return "STOP"
        }
    }
}

final class GestureController: ObservableObject {
    @Published var currentMenu: MenuOption = .brightness
    @Published var isMenuActive: Bool = false
    
    // For one‑finger
    var oneFingerStart: NormalizedPoint?
    
    func resetOneFinger() {
        oneFingerStart = nil
        // isMenuActive will be turned off after timeout
    }
    
    // Loop menu
    func nextMenu() {
        let all = MenuOption.allCases
        if let idx = all.firstIndex(of: currentMenu) {
            currentMenu = all[(idx + 1) % all.count]
        }
    }
    
    func previousMenu() {
        let all = MenuOption.allCases
        if let idx = all.firstIndex(of: currentMenu) {
            currentMenu = all[(idx - 1 + all.count) % all.count]
        }
    }
}