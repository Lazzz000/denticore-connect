import UIKit

final class HomeViewController: UIViewController {
    @IBOutlet private weak var brandImageView: UIImageView!
    @IBOutlet private weak var welcomeLabel: UILabel!
    @IBOutlet private weak var clinicLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var specialtiesButton: UIButton!
    @IBOutlet private weak var appointmentsButton: UIButton!
    @IBOutlet private weak var upcomingAppointmentButton: UIButton!
    @IBOutlet private weak var retryButton: UIButton!

    var patientService: PatientServicing = PatientService()
    var appointmentService: AppointmentServicing = AppointmentService()
    var appointmentCache = AppointmentCache()
    var notificationScheduler: AppointmentNotificationScheduling = LocalNotificationService.shared

    private var upcomingAppointment: PatientAppointment?
    private var isHandlingExpiredSession = false

    private enum Segue {
        static let showSpecialties = "showSpecialties"
        static let showUpcomingAppointment = "showUpcomingAppointment"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        loadPatient()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCachedUpcomingAppointment()
        loadUpcomingAppointment()
    }

    private func configureInterface() {
        title = "Inicio"
        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground

        brandImageView.image = UIImage(named: "BrandLogo")
            ?? UIImage(systemName: "mouth.fill")
        brandImageView.tintColor = DentiCoreTheme.primary
        brandImageView.accessibilityLabel = "DentiCore Connect"

        welcomeLabel.font = .preferredFont(forTextStyle: .title1)
        welcomeLabel.textColor = .label
        welcomeLabel.numberOfLines = 0

        clinicLabel.font = .preferredFont(forTextStyle: .body)
        clinicLabel.textColor = .secondaryLabel
        clinicLabel.numberOfLines = 0

        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        activityIndicator.hidesWhenStopped = true
        DentiCoreTheme.stylePrimaryButton(specialtiesButton)

        configureUpcomingButton(with: nil, isLoading: true)

        DentiCoreTheme.styleSecondaryButton(
            appointmentsButton,
            title: "Ver todas mis citas",
            systemImage: "calendar"
        )

        var retryConfiguration = UIButton.Configuration.tinted()
        retryConfiguration.title = "Reintentar"
        retryConfiguration.baseForegroundColor = DentiCoreTheme.primary
        retryButton.configuration = retryConfiguration
        retryButton.isHidden = true
        specialtiesButton.isEnabled = true
        appointmentsButton.isEnabled = true
    }

    private func loadPatient() {
        setLoading(true)
        errorLabel.isHidden = true
        retryButton.isHidden = true

        patientService.fetchCurrentPatient { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case let .success(patient):
                self.welcomeLabel.text = "Hola, \(patient.firstName)"
                self.clinicLabel.text = patient.clinica.nombreComercial

            case .failure(.unauthorized):
                self.handleExpiredSession()

            case let .failure(error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        retryButton.isHidden = false
    }

    private func handleExpiredSession() {
        guard !isHandlingExpiredSession else { return }
        isHandlingExpiredSession = true
        let alert = UIAlertController(
            title: "Sesión finalizada",
            message: "Vuelve a iniciar sesión para continuar.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { [weak self] _ in
            guard let self else { return }
            AuthenticationFlow.endSession(from: self)
            self.isHandlingExpiredSession = false
        })
        present(alert, animated: true)
    }

    private func loadCachedUpcomingAppointment() {
        guard let patientDNI = SessionManager.shared.patientDNI else { return }

        do {
            let cached = try appointmentCache.fetch(for: patientDNI)
            if let upcoming = nextUpcomingAppointment(in: cached) {
                upcomingAppointment = upcoming
                configureUpcomingButton(with: upcoming, isLoading: false)
            }
        } catch {
            // La consulta remota actualizará el dashboard.
        }
    }

    private func loadUpcomingAppointment() {
        if upcomingAppointment == nil {
            configureUpcomingButton(with: nil, isLoading: true)
        }

        appointmentService.fetchAppointments { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(appointments):
                self.upcomingAppointment = self.nextUpcomingAppointment(
                    in: appointments
                )
                self.configureUpcomingButton(
                    with: self.upcomingAppointment,
                    isLoading: false
                )
                self.persist(appointments)
                self.notificationScheduler.synchronizeIfAuthorized(appointments)

            case .failure(.unauthorized):
                self.handleExpiredSession()

            case .failure:
                if self.upcomingAppointment == nil {
                    self.configureUpcomingUnavailableState()
                }
            }
        }
    }

    private func nextUpcomingAppointment(
        in appointments: [PatientAppointment]
    ) -> PatientAppointment? {
        appointments
            .filter {
                ["PENDIENTE", "CONFIRMADA"].contains($0.estado.uppercased())
                    && (AppointmentPresentation.date(from: $0.fechaHora) ?? .distantPast) > Date()
            }
            .sorted {
                (AppointmentPresentation.date(from: $0.fechaHora) ?? .distantFuture)
                    < (AppointmentPresentation.date(from: $1.fechaHora) ?? .distantFuture)
            }
            .first
    }

    private func persist(_ appointments: [PatientAppointment]) {
        guard let patientDNI = SessionManager.shared.patientDNI else { return }
        try? appointmentCache.replace(appointments, for: patientDNI)
    }

    private func configureUpcomingButton(
        with appointment: PatientAppointment?,
        isLoading: Bool
    ) {
        var configuration = UIButton.Configuration.tinted()
        configuration.image = UIImage(systemName: "calendar.badge.clock")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 14
        configuration.baseForegroundColor = DentiCoreTheme.primary
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 14,
            leading: 16,
            bottom: 14,
            trailing: 16
        )

        if isLoading {
            configuration.title = "Próxima cita"
            configuration.subtitle = "Actualizando agenda…"
            upcomingAppointmentButton.isEnabled = false
        } else if let appointment {
            configuration.title = appointment.servicioNombre
            configuration.subtitle = [
                AppointmentPresentation.formattedDate(appointment.fechaHora),
                appointment.odontologoNombre
            ].joined(separator: "\n")
            upcomingAppointmentButton.isEnabled = true
            upcomingAppointmentButton.accessibilityHint = "Abre el detalle de la cita"
        } else {
            configuration.title = "Sin citas próximas"
            configuration.subtitle = "Programa una atención cuando la necesites."
            upcomingAppointmentButton.isEnabled = false
        }

        configuration.titleLineBreakMode = .byWordWrapping
        configuration.subtitleLineBreakMode = .byWordWrapping
        upcomingAppointmentButton.configuration = configuration
    }

    private func configureUpcomingUnavailableState() {
        var configuration = upcomingAppointmentButton.configuration
            ?? UIButton.Configuration.tinted()
        configuration.title = "No se pudo actualizar la agenda"
        configuration.subtitle = "Puedes revisar tus citas desde el acceso inferior."
        upcomingAppointmentButton.configuration = configuration
        upcomingAppointmentButton.isEnabled = false
    }

    @IBAction private func specialtiesButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: Segue.showSpecialties, sender: nil)
    }

    @IBAction private func appointmentsButtonTapped(_ sender: UIButton) {
        tabBarController?.selectedIndex = 1
    }

    @IBAction private func upcomingAppointmentButtonTapped(_ sender: UIButton) {
        guard let upcomingAppointment else { return }
        performSegue(
            withIdentifier: Segue.showUpcomingAppointment,
            sender: upcomingAppointment
        )
    }

    @IBAction private func retryButtonTapped(_ sender: UIButton) {
        loadPatient()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == Segue.showUpcomingAppointment,
            let destination = segue.destination as? AppointmentDetailViewController,
            let appointment = sender as? PatientAppointment
        else {
            return
        }

        destination.appointment = appointment
    }
}
