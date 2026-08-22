import UIKit

final class LoginViewController: UIViewController {
    @IBOutlet private weak var dniTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!

    var authService: AuthServicing = AuthService()
    var sessionManager: SessionManager = .shared

    private enum Segue {
        static let showMain = "showMain"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
    }

    @IBAction private func loginButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        errorLabel.isHidden = true

        guard let credentials = validatedCredentials() else {
            return
        }

        setLoading(true)

        authService.login(dni: credentials.dni, password: credentials.password) { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case let .success(response):
                self.handleSuccessfulLogin(response)
            case let .failure(error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func configureInterface() {
        title = "DentiCore Connect"
        view.backgroundColor = .systemBackground

        dniTextField.keyboardType = .numberPad
        dniTextField.textContentType = .username
        dniTextField.autocorrectionType = .no
        dniTextField.autocapitalizationType = .none

        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password

        DentiCoreTheme.styleTextField(dniTextField)
        DentiCoreTheme.styleTextField(passwordTextField)
        DentiCoreTheme.stylePrimaryButton(loginButton)

        activityIndicator.hidesWhenStopped = true
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
    }

    private func validatedCredentials() -> (dni: String, password: String)? {
        let dni = dniTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""

        guard dni.count == 8, dni.allSatisfy(\.isNumber) else {
            showError("Ingresa un DNI válido de 8 dígitos.")
            return nil
        }

        guard password.count >= 8 else {
            showError("La contraseña debe tener al menos 8 caracteres.")
            return nil
        }

        return (dni, password)
    }

    private func handleSuccessfulLogin(_ response: LoginResponse) {
        guard response.role.uppercased() == "PACIENTE" else {
            showError("Esta aplicación está disponible únicamente para pacientes.")
            return
        }

        do {
            try sessionManager.startSession(with: response)
            performSegue(withIdentifier: Segue.showMain, sender: response)
        } catch {
            showError("No se pudo guardar la sesión de forma segura.")
        }
    }

    private func setLoading(_ isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        dniTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading

        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}
