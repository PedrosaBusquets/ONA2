import Foundation

final class SettingsManager: ObservableObject {
    @Published var configuration: AppConfiguration {
        didSet { save() }
    }
    
    private let defaultsKey = "ONA2_AppConfiguration"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let config = try? JSONDecoder().decode(AppConfiguration.self, from: data) {
            self.configuration = config
        } else {
            // First launch
            self.configuration = AppConfiguration()
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(configuration) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}