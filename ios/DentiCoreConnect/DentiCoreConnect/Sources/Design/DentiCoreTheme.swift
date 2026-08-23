import UIKit

enum DentiCoreTheme {
    static let primary = UIColor(
        red: 22.0 / 255.0,
        green: 103.0 / 255.0,
        blue: 171.0 / 255.0,
        alpha: 1
    )

    static let accent = UIColor(
        red: 38.0 / 255.0,
        green: 166.0 / 255.0,
        blue: 154.0 / 255.0,
        alpha: 1
    )

    static let surface = UIColor.secondarySystemBackground
    static let cornerRadius: CGFloat = 12
    static let smallSpacing: CGFloat = 8
    static let standardSpacing: CGFloat = 16
    static let horizontalMargin: CGFloat = 20

    static func configureGlobalAppearance() {
        UINavigationBar.appearance().tintColor = primary
        UITabBar.appearance().tintColor = primary
        UIRefreshControl.appearance().tintColor = primary
    }

    static func stylePrimaryButton(_ button: UIButton) {
        button.backgroundColor = primary
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.layer.cornerRadius = cornerRadius
        button.clipsToBounds = true
    }

    static func styleTextField(_ textField: UITextField) {
        textField.backgroundColor = surface
        textField.layer.cornerRadius = cornerRadius
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.separator.cgColor
        textField.clipsToBounds = true
    }

    static func styleDestructiveButton(_ button: UIButton) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = button.title(for: .normal) ?? "Cancelar cita"
        configuration.baseBackgroundColor = .systemRed
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .medium
        button.configuration = configuration
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    }
}
