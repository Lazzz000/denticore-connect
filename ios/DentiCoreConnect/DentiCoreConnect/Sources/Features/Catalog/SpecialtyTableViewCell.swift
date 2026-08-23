import UIKit

final class SpecialtyTableViewCell: UITableViewCell {
    @IBOutlet private weak var specialtyIconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        specialtyIconImageView.tintColor = DentiCoreTheme.primary
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.numberOfLines = 0
        accessoryType = .disclosureIndicator
    }

    func configure(with specialty: Specialty) {
        nameLabel.text = specialty.nombre
        specialtyIconImageView.image = UIImage(systemName: "stethoscope")
        accessibilityLabel = "Especialidad \(specialty.nombre)"
    }
}
