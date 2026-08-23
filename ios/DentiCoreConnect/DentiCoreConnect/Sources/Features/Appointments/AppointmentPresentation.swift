import UIKit

enum AppointmentPresentation {
    static func formattedDate(_ value: String) -> String {
        guard let date = date(from: value) else { return value }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.timeZone = TimeZone(identifier: "America/Lima")
        formatter.dateFormat = "EEEE d 'de' MMMM · h:mm a"
        let text = formatter.string(from: date)
        return text.prefix(1).uppercased() + String(text.dropFirst())
    }

    static func displayStatus(_ value: String) -> String {
        value.replacingOccurrences(of: "_", with: " ").lowercased().capitalizedSentence
    }

    static func statusColor(_ value: String) -> UIColor {
        switch value.uppercased() {
        case "CONFIRMADA", "ATENDIDA":
            return .systemGreen
        case "CANCELADA_PACIENTE", "CANCELADA_CLINICA", "NO_ASISTIO":
            return .systemRed
        case "EN_CURSO", "EN_SALA":
            return DentiCoreTheme.accent
        default:
            return .systemOrange
        }
    }

    static func canPatientCancel(_ appointment: PatientAppointment) -> Bool {
        ["PENDIENTE", "CONFIRMADA"].contains(appointment.estado.uppercased())
    }

    static func date(from value: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fractional.date(from: value) ?? ISO8601DateFormatter().date(from: value)
    }
}

private extension String {
    var capitalizedSentence: String {
        guard let first else { return self }
        return first.uppercased() + String(dropFirst())
    }
}
