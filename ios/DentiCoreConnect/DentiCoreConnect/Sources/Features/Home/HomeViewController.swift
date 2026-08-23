import UIKit

final class HomeViewController: UIViewController {
    @IBOutlet private weak var welcomeLabel: UILabel!
    @IBOutlet private weak var clinicLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var specialtiesButton: UIButton!
    @IBOutlet private weak var appointmentsButton: UIButton!
    @IBOutlet private weak var retryButton: UIButton!

    var patientService: PatientServicing = PatientService()

    private enum Segue {
        static let showSpecialties = "showSpecialties"
        static let showAppointments = "showAppointments"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        loadPatient()
    }

    private func configureInterface() {
        title = "Inicio"
        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground

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

        var appointmentsConfiguration = UIButton.Configuration.tinted()
        appointmentsConfiguration.title = "Mis citas"
        appointmentsConfiguration.image = UIImage(systemName: "calendar")
        appointmentsConfiguration.imagePadding = 8
        appointmentsConfiguration.baseForegroundColor = DentiCoreTheme.primary
        appointmentsButton.configuration = appointmentsConfiguration

        var retryConfiguration = UIButton.Configuration.tinted()
        retryConfiguration.title = "Reintentar"
        retryConfiguration.baseForegroundColor = DentiCoreTheme.primary
        retryButton.configuration = retryConfiguration
        retryButton.isHidden = true
        specialtiesButton.isEnabled = false
        appointmentsButton.isEnabled = false
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
                self.clinicLabel.text = [
                    patient.fullName,
                    "DNI \(patient.dni)",
                    patient.clinica.nombreComercial
                ].joined(separator: "\n")
                self.specialtiesButton.isEnabled = true
                self.appointmentsButton.isEnabled = true

            case .failure(.unauthorized):
                self.handleExpiredSession()

            case let .failure(error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func setLoading(_ isLoading: Bool) {
        specialtiesButton.isEnabled = !isLoading && errorLabel.isHidden
        appointmentsButton.isEnabled = !isLoading && errorLabel.isHidden

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
        specialtiesButton.isEnabled = false
        appointmentsButton.isEnabled = false
    }

    private func handleExpiredSession() {
        SessionManager.shared.clearSession()
        let alert = UIAlertController(
            title: "Sesión finalizada",
            message: "Vuelve a iniciar sesión para continuar.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }

    @IBAction private func specialtiesButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: Segue.showSpecialties, sender: nil)
    }

    @IBAction private func appointmentsButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: Segue.showAppointments, sender: nil)
    }

    @IBAction private func retryButtonTapped(_ sender: UIButton) {
        loadPatient()
    }

    @IBAction private func logoutButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Cerrar sesión",
            message: "¿Deseas salir de DentiCore Connect?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cerrar sesión", style: .destructive) { [weak self] _ in
            SessionManager.shared.clearSession()
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
