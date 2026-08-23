import UIKit

final class ServiceTableViewCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.numberOfLines = 0
        detailsLabel.font = .preferredFont(forTextStyle: .subheadline)
        detailsLabel.textColor = .secondaryLabel
        priceLabel.font = .preferredFont(forTextStyle: .headline)
        priceLabel.textColor = DentiCoreTheme.primary
    }

    func configure(with service: DentalService) {
        nameLabel.text = service.nombre

        var details: [String] = []
        if let code = service.codigo, !code.isEmpty {
            details.append(code)
        }
        if let duration = service.duracionMinutos {
            details.append("\(duration) minutos")
        }
        detailsLabel.text = details.joined(separator: " · ")

        if let price = service.costoReferencial {
            priceLabel.text = String(format: "S/ %.2f", price)
        } else {
            priceLabel.text = "Precio por confirmar"
        }
    }
}
