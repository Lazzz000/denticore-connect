import UIKit

enum DentiCoreTheme {
    // Brand colors. Semantic system colors remain the default for backgrounds and text.
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

    static let primaryDark = UIColor(
        red: 12.0 / 255.0,
        green: 72.0 / 255.0,
        blue: 122.0 / 255.0,
        alpha: 1
    )

    static let success = UIColor.systemGreen
    static let warning = UIColor.systemOrange
    static let danger = UIColor.systemRed
    static let information = UIColor.systemBlue

    static let canvas = UIColor.systemGroupedBackground
    static let surface = UIColor.secondarySystemBackground
    static let elevatedSurface = UIColor.secondarySystemGroupedBackground

    static let compactCornerRadius: CGFloat = 8
    static let cornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 18
    static let smallSpacing: CGFloat = 8
    static let compactSpacing: CGFloat = 12
    static let standardSpacing: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    static let horizontalMargin: CGFloat = 20
    static let controlHeight: CGFloat = 52

    static func configureGlobalAppearance() {
        UINavigationBar.appearance().tintColor = primary
        UINavigationBar.appearance().prefersLargeTitles = false
        UITabBar.appearance().tintColor = primary
        UITabBar.appearance().unselectedItemTintColor = .secondaryLabel
        UIRefreshControl.appearance().tintColor = primary
    }

    static func stylePrimaryButton(_ button: UIButton) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = button.configuration?.title
            ?? button.title(for: .normal)
        configuration.baseBackgroundColor = primary
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 14,
            leading: 20,
            bottom: 14,
            trailing: 20
        )
        button.configuration = configuration
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    static func styleSecondaryButton(
        _ button: UIButton,
        title: String? = nil,
        systemImage: String? = nil
    ) {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = title
            ?? button.configuration?.title
            ?? button.title(for: .normal)
        if let systemImage {
            configuration.image = UIImage(systemName: systemImage)
            configuration.imagePadding = smallSpacing
        }
        configuration.baseForegroundColor = primary
        configuration.baseBackgroundColor = primary.withAlphaComponent(0.12)
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 18,
            bottom: 12,
            trailing: 18
        )
        button.configuration = configuration
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    static func styleTextField(_ textField: UITextField) {
        textField.backgroundColor = surface
        textField.layer.cornerRadius = cornerRadius
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.separator.cgColor
        textField.clipsToBounds = true
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
    }

    static func styleCard(_ view: UIView) {
        view.backgroundColor = elevatedSurface
        view.layer.cornerRadius = largeCornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        view.clipsToBounds = true
    }

    static func styleSectionTitle(_ label: UILabel) {
        label.font = .preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
    }

    static func styleDestructiveButton(
        _ button: UIButton,
        title: String? = nil
    ) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
            ?? button.configuration?.title
            ?? button.title(for: .normal)
            ?? "Cancelar cita"
        configuration.baseBackgroundColor = .systemRed
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large
        button.configuration = configuration
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
    }
}
