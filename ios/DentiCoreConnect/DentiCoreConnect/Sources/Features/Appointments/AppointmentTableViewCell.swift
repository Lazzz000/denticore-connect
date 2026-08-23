import UIKit

final class AppointmentTableViewCell: UITableViewCell {
    @IBOutlet private weak var serviceLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var dentistLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        serviceLabel.font = .preferredFont(forTextStyle: .headline)
        serviceLabel.numberOfLines = 0
        dateLabel.font = .preferredFont(forTextStyle: .subheadline)
        dateLabel.textColor = DentiCoreTheme.primary
        dentistLabel.font = .preferredFont(forTextStyle: .subheadline)
        dentistLabel.textColor = .secondaryLabel
        dentistLabel.numberOfLines = 0
        statusLabel.font = .preferredFont(forTextStyle: .caption1)
        statusLabel.numberOfLines = 0
    }

    func configure(with appointment: PatientAppointment) {
        serviceLabel.text = appointment.servicioNombre
        dateLabel.text = Self.formattedDate(appointment.fechaHora)
        dentistLabel.text = "(appointment.odontologoNombre) · (appointment.sedeNombre)"
        statusLabel.text = Self.displayStatus(appointment.estado)
        statusLabel.textColor = Self.statusColor(appointment.estado)
    }

    private static func formattedDate(_ value: String) -> String {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = fractional.date(from: value) ?? ISO8601DateFormatter().date(from: value)

        guard let date else { return value }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.timeZone = TimeZone(identifier: "America/Lima")
        formatter.dateFormat = "EEEE d 'de' MMMM · h:mm a"
        return formatter.string(from: date).capitalized
    }

    private static func displayStatus(_ value: String) -> String {
        value.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private static func statusColor(_ value: String) -> UIColor {
        switch value.uppercased() {
        case "CONFIRMADA", "COMPLETADA":
            return .systemGreen
        case "CANCELADA", "NO_ASISTIO":
            return .systemRed
        case "EN_CURSO", "EN_SALA":
            return DentiCoreTheme.accent
        default:
            return .systemOrange
        }
    }
}
