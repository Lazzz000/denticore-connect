import XCTest
@testable import DentiCoreConnect

final class PatientIdentityPresentationTests: XCTestCase {
    func testDNIIsMaskedByDefault() {
        XCTAssertEqual(
            PatientIdentityPresentation.displayDNI("70401478", revealed: false),
            "DNI: •••• 1478"
        )
    }

    func testDNIIsCompleteWhenRevealed() {
        XCTAssertEqual(
            PatientIdentityPresentation.displayDNI("70401478", revealed: true),
            "DNI: 70401478"
        )
    }
}
