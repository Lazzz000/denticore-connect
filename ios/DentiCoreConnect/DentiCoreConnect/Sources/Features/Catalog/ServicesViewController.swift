import UIKit

final class ServicesViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!

    var specialty: Specialty!
    var catalogService: CatalogServicing = CatalogService()

    private var services: [DentalService] = []
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        loadServices()
    }

    private func configureInterface() {
        title = specialty?.nombre ?? "Servicios"
        view.backgroundColor = .systemGroupedBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96

        refreshControl.addTarget(self, action: #selector(refreshServices), for: .valueChanged)
        tableView.refreshControl = refreshControl

        activityIndicator.hidesWhenStopped = true
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        retryButton.isHidden = true
    }

    private func loadServices() {
        guard let specialty else {
            showError("No se recibió la especialidad seleccionada.")
            return
        }

        showLoading()

        catalogService.fetchServices(specialtyID: specialty.id) { [weak self] result in
            guard let self else { return }
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()

            switch result {
            case let .success(items):
                self.services = items.filter { $0.activo != false }
                self.errorLabel.isHidden = true
                self.retryButton.isHidden = true
                self.tableView.isHidden = false
                self.tableView.reloadData()

            case .failure(.unauthorized):
                SessionManager.shared.clearSession()
                self.navigationController?.popToRootViewController(animated: true)

            case let .failure(error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func showLoading() {
        errorLabel.isHidden = true
        retryButton.isHidden = true

        if services.isEmpty {
            tableView.isHidden = true
            activityIndicator.startAnimating()
        }
    }

    private func showError(_ message: String) {
        activityIndicator.stopAnimating()

        if services.isEmpty {
            tableView.isHidden = true
            errorLabel.text = message
            errorLabel.isHidden = false
            retryButton.isHidden = false
        }
    }

    @IBAction private func retryButtonTapped(_ sender: UIButton) {
        loadServices()
    }

    @objc private func refreshServices() {
        loadServices()
    }
}

extension ServicesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        services.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ServiceCell",
            for: indexPath
        ) as? ServiceTableViewCell else {
            assertionFailure("ServiceCell no está configurada en Main.storyboard")
            return UITableViewCell()
        }

        cell.configure(with: services[indexPath.row])
        return cell
    }
}
