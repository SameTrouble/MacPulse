@testable import MacPulse
import XCTest

final class SMCTemperatureDecoderTests: XCTestCase {
    func testDecodesSP78() {
        XCTAssertEqual(SMCTemperatureDecoder.decode(bytes: [0x2A, 0x80], dataType: "sp78"), 42.5)
    }

    func testDecodesNegativeSP78() {
        XCTAssertEqual(SMCTemperatureDecoder.decode(bytes: [0xFF, 0x00], dataType: "sp78"), -1)
    }

    func testDecodesFloat() {
        let bytes = withUnsafeBytes(of: Float(42.5)) { Array($0) }

        XCTAssertEqual(SMCTemperatureDecoder.decode(bytes: bytes, dataType: "flt "), 42.5)
    }

    func testDecodesUInt16BigEndian() {
        XCTAssertEqual(SMCTemperatureDecoder.decode(bytes: [0x00, 0x10], dataType: "ui16"), 16)
    }

    func testDecodesUInt8() {
        XCTAssertEqual(SMCTemperatureDecoder.decode(bytes: [0x2A], dataType: "ui8"), 42)
    }

    func testUnknownTypeReturnsNil() {
        XCTAssertNil(SMCTemperatureDecoder.decode(bytes: [0x2A, 0x80], dataType: "flt1"))
    }

    func testTooFewBytesReturnsNil() {
        XCTAssertNil(SMCTemperatureDecoder.decode(bytes: [0x2A], dataType: "sp78"))
    }
}
