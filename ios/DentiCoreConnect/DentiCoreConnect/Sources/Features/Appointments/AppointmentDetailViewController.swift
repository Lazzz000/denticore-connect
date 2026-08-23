import UIKit

final class AppointmentDetailViewController: UIViewController {
    @IBOutlet private weak var serviceLabel: UILabel!
    @IBOutlet private weak var specialtyLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var dentistLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var notesLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!

    var appointment: PatientAppointment!
    var appointmentService: AppointmentServicing = AppointmentService()
    var notificationScheduler: AppointmentNotificationScheduling = LocalNotificationService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        renderAppointment()
        refreshAppointment()
    }

    private func configureInterface() {
        title = "Detalle de cita"
        view.backgroundColor = .systemGroupedBackground

        serviceLabel.font = .preferredFont(forTextStyle: .title2)
        serviceLabel.numberOfLines = 0
        specialtyLabel.font = .preferredFont(forTextStyle: .subheadline)
        specialtyLabel.textColor = .secondaryLabel
        statusLabel.font = .preferredFont(forTextStyle: .headline)
        dateLabel.font = .preferredFont(forTextStyle: .headline)
        dateLabel.textColor = DentiCoreTheme.primary
        dentistLabel.numberOfLines = 0
        locationLabel.numberOfLines = 0
        notesLabel.numberOfLines = 0
        notesLabel.textColor = .secondaryLabel
        activityIndicator.hidesWhenStopped = true
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        DentiCoreTheme.styleDestructiveButton(cancelButton)
    }

    private func refreshAppointment() {
        guard let appointment else { return }
        setLoading(true)

        appointmentService.fetchAppointment(id: appointment.id) { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case let .success(updated):
                self.appointment = updated
                self.renderAppointment()
            case .failure(.unauthorized):
                AuthenticationFlow.endSession(from: self)
            case let .failure(error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func renderAppointment() {
        guard let appointment else { return }
        serviceLabel.text = appointment.servicioNombre
        specialtyLabel.text = appointment.especialidadNombre ?? "Atención odontológica"
        statusLabel.text = AppointmentPresentation.displayStatus(appointment.estado)
        statusLabel.textColor = AppointmentPresentation.statusColor(appointment.estado)
        dateLabel.text = AppointmentPresentation.formattedDate(appointment.fechaHora)
        dentistLabel.text = appointment.odontologoNombre
        locationLabel.text = appointment.sedeNombre

        let note = appointment.notaPaciente?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        notesLabel.text = note?.isEmpty == false ? note : "Sin indicaciones adicionales."
        cancelButton.isHidden = !AppointmentPresentation.canPatientCancel(appointment)
    }

    @IBAction private func cancelButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Cancelar cita",
            message: "Esta acción liberará el horario seleccionado.",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Motivo (opcional)"
            textField.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: "Volver", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cancelar cita", style: .destructive) { [weak self, weak alert] _ in
            let reason = alert?.textFields?.first?.text?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self?.cancelAppointment(reason: reason)
        })
        present(alert, animated: true)
    }

    private func cancelAppointment(reason: String?) {
        guard let appointment else { return }
        let normalizedReason: String?
        if let reason, !reason.isEmpty {
            normalizedReason = String(reason.prefix(300))
        } else {
            normalizedReason = nil
        }
        setLoading(true)

        appointmentService.cancelAppointment(
            id: appointment.id,
            reason: normalizedReason
        ) { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case let .success(updated):
                self.appointment = updated
                self.notificationScheduler.removeReminders(
                    forAppointmentID: updated.id
                )
                self.renderAppointment()
                self.showCancellationSuccess(updated.mensaje)
            case .failure(.unauthorized):
                AuthenticationFlow.endSession(from: self)
            case let .failure(error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func setLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        cancelButton.isEnabled = !isLoading
        if isLoading { errorLabel.isHidden = true }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func showCancellationSuccess(_ message: String?) {
        let alert = UIAlertController(
            title: "Cita cancelada",
            message: message ?? "El horario fue liberado correctamente.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}
