import XCTest
@testable import DentiCoreConnect

final class PatientIdentityPresentationTests: XCTestCase {
    func testDNIIsMaskedByDefault() {
        XCTAssertEqual(
            PatientIdentityPresentation.displayDNI("00000000", revealed: false),
            "DNI: •••• 0000"
        )
    }

    func testDNIIsCompleteWhenRevealed() {
        XCTAssertEqual(
            PatientIdentityPresentation.displayDNI("00000000", revealed: true),
            "DNI: 00000000"
        )
    }
}
