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
        dateLabel.text = AppointmentPresentation.formattedDate(appointment.fechaHora)
        dentistLabel.text = "\(appointment.odontologoNombre) · \(appointment.sedeNombre)"
        statusLabel.text = AppointmentPresentation.displayStatus(appointment.estado)
        statusLabel.textColor = AppointmentPresentation.statusColor(appointment.estado)
    }
}
