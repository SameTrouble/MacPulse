import Foundation

struct ConfigurationStore {
    static let key = "configuration"

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> AppConfiguration? {
        guard let data = defaults.data(forKey: Self.key) else { return nil }
        do {
            return try decoder.decode(AppConfiguration.self, from: data)
        } catch {
            return nil
        }
    }

    func save(_ configuration: AppConfiguration) throws {
        defaults.set(try encoder.encode(configuration), forKey: Self.key)
    }
}
