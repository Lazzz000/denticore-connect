import UIKit

final class SpecialtiesViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!

    var catalogService: CatalogServicing = CatalogService()

    private var specialties: [Specialty] = []
    private let refreshControl = UIRefreshControl()

    private enum Segue {
        static let showServices = "showServices"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        loadSpecialties()
    }

    private func configureInterface() {
        title = "Especialidades"
        view.backgroundColor = .systemGroupedBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72

        refreshControl.addTarget(self, action: #selector(refreshSpecialties), for: .valueChanged)
        tableView.refreshControl = refreshControl

        activityIndicator.hidesWhenStopped = true
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        retryButton.isHidden = true
    }

    private func loadSpecialties() {
        showLoading()

        catalogService.fetchSpecialties { [weak self] result in
            guard let self else { return }
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()

            switch result {
            case let .success(items):
                self.specialties = items
                self.errorLabel.isHidden = true
                self.retryButton.isHidden = true
                self.tableView.isHidden = false
                self.tableView.reloadData()

            case .failure(.unauthorized):
                self.handleExpiredSession()

            case let .failure(error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func showLoading() {
        errorLabel.isHidden = true
        retryButton.isHidden = true

        if specialties.isEmpty {
            tableView.isHidden = true
            activityIndicator.startAnimating()
        }
    }

    private func showError(_ message: String) {
        activityIndicator.stopAnimating()

        if specialties.isEmpty {
            tableView.isHidden = true
            errorLabel.text = message
            errorLabel.isHidden = false
            retryButton.isHidden = false
        } else {
            let alert = UIAlertController(
                title: "No se pudo actualizar",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
            present(alert, animated: true)
        }
    }

    private func handleExpiredSession() {
        SessionManager.shared.clearSession()
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction private func retryButtonTapped(_ sender: UIButton) {
        loadSpecialties()
    }

    @objc private func refreshSpecialties() {
        loadSpecialties()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == Segue.showServices,
            let destination = segue.destination as? ServicesViewController,
            let specialty = sender as? Specialty
        else {
            return
        }

        destination.specialty = specialty
    }
}

extension SpecialtiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        specialties.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SpecialtyCell",
            for: indexPath
        ) as? SpecialtyTableViewCell else {
            assertionFailure("SpecialtyCell no está configurada en Main.storyboard")
            return UITableViewCell()
        }

        cell.configure(with: specialties[indexPath.row])
        return cell
    }
}

extension SpecialtiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(
            withIdentifier: Segue.showServices,
            sender: specialties[indexPath.row]
        )
    }
}
