import UIKit

final class AppointmentViewController: UIViewController {
    @IBOutlet private weak var serviceNameLabel: UILabel!
    @IBOutlet private weak var serviceDetailsLabel: UILabel!
    @IBOutlet private weak var dentistPickerView: UIPickerView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var timePickerView: UIPickerView!
    @IBOutlet private weak var notesTextView: UITextView!
    @IBOutlet private weak var bookButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!

    var specialty: Specialty!
    var dentalService: DentalService!
    var appointmentService: AppointmentServicing = AppointmentService()

    private var dentists: [Dentist] = []
    private var slots: [AvailabilitySlot] = []

    private lazy var requestDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/Lima")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.timeZone = TimeZone(identifier: "America/Lima")
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        loadDentists()
    }

    private func configureInterface() {
        title = "Programar cita"
        view.backgroundColor = .systemGroupedBackground

        serviceNameLabel.text = dentalService?.nombre ?? "Servicio odontológico"
        let duration = dentalService?.duracionMinutos ?? 30
        serviceDetailsLabel.text = "\(specialty?.nombre ?? "Especialidad") · \(duration) min"

        dentistPickerView.dataSource = self
        dentistPickerView.delegate = self
        timePickerView.dataSource = self
        timePickerView.delegate = self

        let today = Date()
        datePicker.minimumDate = today
        datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 60, to: today)
        datePicker.date = nextDemoBusinessDate(after: today)
        datePicker.locale = Locale(identifier: "es_PE")

        notesTextView.layer.cornerRadius = 10
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.separator.cgColor
        notesTextView.text = ""

        activityIndicator.hidesWhenStopped = true
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        bookButton.isEnabled = false
    }

    private func loadDentists() {
        guard let specialty else {
            showError("No se recibió la especialidad seleccionada.")
            return
        }

        setLoading(true)
        appointmentService.fetchDentists(specialtyID: specialty.id) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(items):
                self.dentists = items
                self.dentistPickerView.reloadAllComponents()

                guard !items.isEmpty else {
                    self.setLoading(false)
                    self.showError("No hay odontólogos disponibles para esta especialidad.")
                    return
                }

                self.dentistPickerView.selectRow(0, inComponent: 0, animated: false)
                self.loadAvailability()

            case .failure(.unauthorized):
                self.handleExpiredSession()

            case let .failure(error):
                self.setLoading(false)
                self.showError(error.localizedDescription)
            }
        }
    }

    private func loadAvailability() {
        guard
            let dentalService,
            let dentist = selectedDentist
        else {
            setLoading(false)
            return
        }

        setLoading(true)
        slots = []
        timePickerView.reloadAllComponents()
        bookButton.isEnabled = false

        appointmentService.fetchAvailability(
            dentistID: dentist.id,
            serviceID: dentalService.id,
            date: requestDateFormatter.string(from: datePicker.date)
        ) { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case let .success(items):
                self.slots = items
                self.timePickerView.reloadAllComponents()
                self.errorLabel.isHidden = !items.isEmpty
                self.errorLabel.text = items.isEmpty
                    ? "No hay horarios disponibles para la fecha seleccionada."
                    : nil
                self.bookButton.isEnabled = !items.isEmpty

                if !items.isEmpty {
                    self.timePickerView.selectRow(0, inComponent: 0, animated: false)
                }

            case .failure(.unauthorized):
                self.handleExpiredSession()

            case let .failure(error):
                self.showError(error.localizedDescription)
            }
        }
    }

    @IBAction private func dateChanged(_ sender: UIDatePicker) {
        loadAvailability()
    }

    @IBAction private func bookButtonTapped(_ sender: UIButton) {
        guard
            let dentalService,
            let dentist = selectedDentist,
            let slot = selectedSlot
        else {
            showError("Selecciona un odontólogo y un horario disponible.")
            return
        }

        let note = notesTextView.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let request = CreateAppointmentRequest(
            idOdontologo: dentist.id,
            idServicio: dentalService.id,
            fechaHora: slot.fechaHoraInicio,
            notaPaciente: note.isEmpty ? nil : String(note.prefix(300))
        )

        setLoading(true)
        appointmentService.createAppointment(request) { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case let .success(appointment):
                self.showSuccess(appointment)

            case .failure(.unauthorized):
                self.handleExpiredSession()

            case let .failure(error):
                self.showError(error.localizedDescription)
                self.loadAvailability()
            }
        }
    }

    private var selectedDentist: Dentist? {
        guard !dentists.isEmpty else { return nil }
        let row = dentistPickerView.selectedRow(inComponent: 0)
        guard dentists.indices.contains(row) else { return nil }
        return dentists[row]
    }

    private var selectedSlot: AvailabilitySlot? {
        guard !slots.isEmpty else { return nil }
        let row = timePickerView.selectedRow(inComponent: 0)
        guard slots.indices.contains(row) else { return nil }
        return slots[row]
    }

    private func setLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        bookButton.isEnabled = !isLoading && !slots.isEmpty
        dentistPickerView.isUserInteractionEnabled = !isLoading
        datePicker.isUserInteractionEnabled = !isLoading
        timePickerView.isUserInteractionEnabled = !isLoading

        if isLoading {
            errorLabel.isHidden = true
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func showSuccess(_ appointment: PatientAppointment) {
        let dateText = formatDateTime(appointment.fechaHora)
        let message = "\(appointment.mensaje ?? "La cita fue registrada.")\n\n\(dateText)\n\(appointment.odontologoNombre)\n\(appointment.sedeNombre)"
        let alert = UIAlertController(
            title: "¡Cita programada!",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { [weak self] _ in
            guard let self else { return }
            if let home = self.navigationController?.viewControllers
                .first(where: { $0 is HomeViewController }) {
                self.navigationController?.popToViewController(home, animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        })
        present(alert, animated: true)
    }

    private func formatDateTime(_ value: String) -> String {
        guard let date = parseISO8601(value) else { return value }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.timeZone = TimeZone(identifier: "America/Lima")
        formatter.dateFormat = "EEEE d 'de' MMMM · h:mm a"
        return formatter.string(from: date).capitalized
    }

    private func nextDemoBusinessDate(after date: Date) -> Date {
        var candidate = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
        while Calendar.current.component(.weekday, from: candidate) == 1 {
            candidate = Calendar.current.date(byAdding: .day, value: 1, to: candidate)
                ?? candidate
        }
        return candidate
    }

    private func parseISO8601(_ value: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: value) {
            return date
        }
        return ISO8601DateFormatter().date(from: value)
    }

    private func handleExpiredSession() {
        SessionManager.shared.clearSession()
        navigationController?.popToRootViewController(animated: true)
    }
}

extension AppointmentViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView === dentistPickerView ? dentists.count : slots.count
    }
}

extension AppointmentViewController: UIPickerViewDelegate {
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        if pickerView === dentistPickerView {
            guard dentists.indices.contains(row) else { return nil }
            return dentists[row].nombreCompleto
        }

        guard slots.indices.contains(row) else { return nil }
        return parseISO8601(slots[row].fechaHoraInicio)
            .map { timeFormatter.string(from: $0) }
            ?? slots[row].fechaHoraInicio
    }

    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        if pickerView === dentistPickerView {
            loadAvailability()
        }
    }
}
