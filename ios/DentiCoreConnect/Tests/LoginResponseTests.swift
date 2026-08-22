import XCTest
@testable import DentiCoreConnect

final class LoginResponseTests: XCTestCase {
    func testDecodesLegacyBackendResponse() throws {
        let json = """
        {
          "token": "legacy.jwt.token",
          "rol": "PACIENTE"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(LoginResponse.self, from: json)

        XCTAssertEqual(response.accessToken, "legacy.jwt.token")
        XCTAssertEqual(response.tokenType, "Bearer")
        XCTAssertEqual(response.role, "PACIENTE")
        XCTAssertNil(response.clinicContext)
    }

    func testDecodesTargetReleaseResponse() throws {
        let json = """
        {
          "accessToken": "release.jwt.token",
          "tokenType": "Bearer",
          "expiresIn": 3600,
          "rol": "PACIENTE",
          "contextoClinica": {
            "id": 1,
            "nombreComercial": "Clínica Dental Demo",
            "zonaHoraria": "America/Lima"
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(LoginResponse.self, from: json)

        XCTAssertEqual(response.accessToken, "release.jwt.token")
        XCTAssertEqual(response.expiresIn, 3600)
        XCTAssertEqual(response.clinicContext?.id, 1)
        XCTAssertEqual(response.clinicContext?.zonaHoraria, "America/Lima")
    }
}
