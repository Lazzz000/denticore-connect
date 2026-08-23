import UIKit
@preconcurrency import UserNotifications

final class ProfileViewController: UIViewController {
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dniLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var clinicLabel: UILabel!
    @IBOutlet private weak var notificationStatusLabel: UILabel!
    @IBOutlet private weak var notificationButton: UIButton!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!
    @IBOutlet private weak var logoutButton: UIButton!

    var patientService: PatientServicing = PatientService()
    var notificationService: AppointmentNotificationScheduling = LocalNotificationService.shared

    private var isHandlingExpiredSession = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        loadPatient()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNotificationStatus()
    }

    private func configureInterface() {
        title = "Perfil"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = DentiCoreTheme.canvas

        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = DentiCoreTheme.primary
        avatarImageView.accessibilityLabel = "Perfil del paciente"

        nameLabel.font = .preferredFont(forTextStyle: .title2)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 0

        [dniLabel, emailLabel, clinicLabel, notificationStatusLabel, versionLabel]
            .forEach {
                $0?.font = .preferredFont(forTextStyle: .body)
                $0?.adjustsFontForContentSizeCategory = true
                $0?.numberOfLines = 0
            }

        dniLabel.textColor = .secondaryLabel
        emailLabel.textColor = .secondaryLabel
        clinicLabel.textColor = .secondaryLabel
        notificationStatusLabel.textColor = .secondaryLabel
        versionLabel.textColor = .tertiaryLabel

        DentiCoreTheme.styleSecondaryButton(
            notificationButton,
            title: "Configurar notificaciones",
            systemImage: "bell.badge"
        )
        DentiCoreTheme.styleDestructiveButton(
            logoutButton,
            title: "Cerrar sesión"
        )
        DentiCoreTheme.styleSecondaryButton(retryButton, title: "Reintentar")

        activityIndicator.hidesWhenStopped = true
        errorLabel.textColor = DentiCoreTheme.danger
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        retryButton.isHidden = true

        versionLabel.text = appVersionText()
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
                self.render(patient)
            case .failure(.unauthorized):
                self.handleExpiredSession()
            case let .failure(error):
                self.errorLabel.text = error.localizedDescription
                self.errorLabel.isHidden = false
                self.retryButton.isHidden = false
            }
        }
    }

    private func render(_ patient: PatientProfile) {
        nameLabel.text = patient.fullName
        dniLabel.text = "DNI: \(maskedDNI(patient.dni))"

        let email = patient.correo?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let displayedEmail = email.flatMap { $0.isEmpty ? nil : $0 }
            ?? "No registrado"
        emailLabel.text = "Correo: \(displayedEmail)"
        clinicLabel.text = "Clínica: \(patient.clinica.nombreComercial)"
        errorLabel.isHidden = true
        retryButton.isHidden = true
    }

    private func maskedDNI(_ dni: String) -> String {
        guard dni.count > 4 else { return dni }
        return "•••• \(dni.suffix(4))"
    }

    private func appVersionText() -> String {
        let dictionary = Bundle.main.infoDictionary
        let version = dictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
        let build = dictionary?["CFBundleVersion"] as? String ?? "1"
        return "DentiCore Connect · Versión \(version) (\(build))"
    }

    private func updateNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self else { return }

                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.notificationStatusLabel.text = "Recordatorios locales activados"
                    DentiCoreTheme.styleSecondaryButton(
                        self.notificationButton,
                        title: "Administrar notificaciones",
                        systemImage: "bell.fill"
                    )
                case .denied:
                    self.notificationStatusLabel.text = "Notificaciones desactivadas"
                    DentiCoreTheme.styleSecondaryButton(
                        self.notificationButton,
                        title: "Abrir Configuración",
                        systemImage: "gearshape"
                    )
                case .notDetermined:
                    self.notificationStatusLabel.text = "Permiso pendiente"
                    DentiCoreTheme.styleSecondaryButton(
                        self.notificationButton,
                        title: "Activar recordatorios",
                        systemImage: "bell.badge"
                    )
                @unknown default:
                    self.notificationStatusLabel.text = "Estado no disponible"
                }
            }
        }
    }

    @IBAction private func notificationButtonTapped(_ sender: UIButton) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self else { return }

                if settings.authorizationStatus == .notDetermined {
                    self.notificationService.requestAuthorization { [weak self] _ in
                        self?.updateNotificationStatus()
                    }
                } else if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    @IBAction private func retryButtonTapped(_ sender: UIButton) {
        loadPatient()
    }

    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Cerrar sesión",
            message: "¿Deseas salir de DentiCore Connect?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cerrar sesión", style: .destructive) { [weak self] _ in
            guard let self else { return }
            AuthenticationFlow.endSession(from: self)
        })
        present(alert, animated: true)
    }

    private func setLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        retryButton.isEnabled = !isLoading
        logoutButton.isEnabled = !isLoading
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
}
