import Foundation

nonisolated enum PatientIdentityPresentation {
    static func displayDNI(_ dni: String, revealed: Bool) -> String {
        "DNI: \(revealed ? dni : maskedDNI(dni))"
    }

    static func maskedDNI(_ dni: String) -> String {
        guard dni.count > 4 else { return dni }
        return "•••• \(dni.suffix(4))"
    }
}
