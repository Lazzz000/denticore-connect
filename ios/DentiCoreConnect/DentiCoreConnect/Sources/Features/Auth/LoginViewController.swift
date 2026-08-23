import UIKit

final class LoginViewController: UIViewController {
    @IBOutlet private weak var brandImageView: UIImageView!
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setLoading(false)
        errorLabel.isHidden = true
        passwordTextField.text = nil
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
                self.handleSuccessfulLogin(response, patientDNI: credentials.dni)
            case let .failure(error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func configureInterface() {
        title = nil
        view.backgroundColor = DentiCoreTheme.canvas

        brandImageView.image = UIImage(named: "BrandLogo")
            ?? UIImage(systemName: "mouth.fill")
        brandImageView.tintColor = DentiCoreTheme.primary
        brandImageView.accessibilityLabel = "DentiCore Connect"

        dniTextField.keyboardType = .numberPad
        dniTextField.textContentType = .username
        dniTextField.autocorrectionType = .no
        dniTextField.autocapitalizationType = .none

        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password
        passwordTextField.returnKeyType = .go

        DentiCoreTheme.styleTextField(dniTextField)
        DentiCoreTheme.styleTextField(passwordTextField)
        configureLeftIcon("person.text.rectangle", for: dniTextField)
        configureLeftIcon("lock", for: passwordTextField)
        configurePasswordVisibilityButton()
        DentiCoreTheme.stylePrimaryButton(loginButton)

        activityIndicator.hidesWhenStopped = true
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
    }

    private func configureLeftIcon(_ systemName: String, for textField: UITextField) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 24))
        let imageView = UIImageView(image: UIImage(systemName: systemName))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 14, y: 2, width: 20, height: 20)
        container.addSubview(imageView)
        textField.leftView = container
        textField.leftViewMode = .always
    }

    private func configurePasswordVisibilityButton() {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.tintColor = .secondaryLabel
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.accessibilityLabel = "Mostrar contraseña"
        button.addTarget(
            self,
            action: #selector(togglePasswordVisibility(_:)),
            for: .touchUpInside
        )
        passwordTextField.rightView = button
        passwordTextField.rightViewMode = .always
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let isHidden = passwordTextField.isSecureTextEntry
        sender.setImage(
            UIImage(systemName: isHidden ? "eye" : "eye.slash"),
            for: .normal
        )
        sender.accessibilityLabel = isHidden
            ? "Mostrar contraseña"
            : "Ocultar contraseña"
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

    private func handleSuccessfulLogin(_ response: LoginResponse, patientDNI: String) {
        guard response.role.uppercased() == "PACIENTE" else {
            showError("Esta aplicación está disponible únicamente para pacientes.")
            return
        }

        do {
            try sessionManager.startSession(with: response, patientDNI: patientDNI)
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
