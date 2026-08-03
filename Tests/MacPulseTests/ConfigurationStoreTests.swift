@testable import MacPulse
import XCTest

final class ConfigurationStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = UUID().uuidString
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testLoadReturnsNilWhenNothingSaved() {
        let store = ConfigurationStore(defaults: defaults)

        XCTAssertNil(store.load())
    }

    func testSavedConfigurationRoundTrips() throws {
        let store = ConfigurationStore(defaults: defaults)
        let item = try CarouselItem(metricID: "cpu", style: .text, duration: 5)
        var configuration = AppConfiguration(placeholders: [Placeholder(id: UUID(), items: [item])])
        configuration.samplingIntervals["cpu"] = 4

        try store.save(configuration)

        XCTAssertEqual(store.load(), configuration)
    }

    func testLoadIgnoresCorruptedPayload() {
        defaults.set(Data([0x00, 0xFF]), forKey: ConfigurationStore.key)
        let store = ConfigurationStore(defaults: defaults)

        XCTAssertNil(store.load())
    }
}
