import XCTest
@testable import DentiCoreConnect

final class CatalogModelsTests: XCTestCase {
    func testPatientProfileDecoding() throws {
        let json = Data(
            #"""
            {
              "id": 10,
              "dni": "00000000",
              "nombres": "Carlos Miguel",
              "apellidos": "Lazo Dominguez",
              "correo": "paciente@denticore.demo",
              "fechaNacimiento": "1992-04-15",
              "clinica": {
                "id": 1,
                "nombreComercial": "Clínica Dental Dr. Dave Cáceres",
                "zonaHoraria": "America/Lima"
              }
            }
            """#.utf8
        )

        let profile = try JSONDecoder().decode(PatientProfile.self, from: json)

        XCTAssertEqual(profile.fullName, "Carlos Miguel Lazo Dominguez")
        XCTAssertEqual(profile.firstName, "Carlos")
        XCTAssertEqual(profile.clinica.nombreComercial, "Clínica Dental Dr. Dave Cáceres")
    }

    func testSpecialtiesAndServicesDecoding() throws {
        let specialtiesJSON = Data(
            #"""
            [{ "id": 1, "nombre": "Odontología general" }]
            """#.utf8
        )
        let servicesJSON = Data(
            #"""
            [{
              "id": 11,
              "codigo": "ODG-001",
              "nombre": "Evaluación dental",
              "especialidadId": 1,
              "duracionMinutos": 30,
              "costoReferencial": 80.00,
              "moneda": "PEN",
              "activo": true
            }]
            """#.utf8
        )

        let specialties = try JSONDecoder().decode([Specialty].self, from: specialtiesJSON)
        let services = try JSONDecoder().decode([DentalService].self, from: servicesJSON)

        XCTAssertEqual(specialties.first?.nombre, "Odontología general")
        XCTAssertEqual(services.first?.especialidadId, 1)
        XCTAssertEqual(services.first?.costoReferencial, 80.0)
    }

    func testAPIClientBuildsSpecialtyQuery() throws {
        let client = APIClient(
            baseURL: try XCTUnwrap(URL(string: "https://example.com/api/v1"))
        )

        let request = try client.makeRequest(
            path: "/servicios",
            method: "GET",
            bearerToken: "demo-token",
            queryItems: [URLQueryItem(name: "especialidadId", value: "3")]
        )

        XCTAssertEqual(
            request.url?.absoluteString,
            "https://example.com/api/v1/servicios?especialidadId=3"
        )
        XCTAssertEqual(
            request.value(forHTTPHeaderField: "Authorization"),
            "Bearer demo-token"
        )
    }
}
