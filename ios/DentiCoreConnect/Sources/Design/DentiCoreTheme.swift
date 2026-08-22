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
}
