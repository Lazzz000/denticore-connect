import UIKit

final class AppointmentsListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!

    var appointmentService: AppointmentServicing = AppointmentService()
    var appointmentCache = AppointmentCache()

    private var appointments: [PatientAppointment] = []
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        loadCachedAppointments()
        loadRemoteAppointments()
    }

    private func configureInterface() {
        title = "Mis citas"
        view.backgroundColor = .systemGroupedBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 116
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()

        refreshControl.addTarget(self, action: #selector(refreshAppointments), for: .valueChanged)
        activityIndicator.hidesWhenStopped = true
        stateLabel.numberOfLines = 0
        stateLabel.textAlignment = .center
        stateLabel.textColor = .secondaryLabel
        stateLabel.isHidden = true
        retryButton.isHidden = true
    }

    private func loadCachedAppointments() {
        guard let patientDNI = SessionManager.shared.patientDNI else { return }

        do {
            appointments = try appointmentCache.fetch(for: patientDNI)
            tableView.reloadData()
            updateEmptyState(isOffline: !appointments.isEmpty)
        } catch {
            appointments = []
        }
    }

    private func loadRemoteAppointments() {
        setLoading(true)

        appointmentService.fetchAppointments { [weak self] result in
            guard let self else { return }
            self.setLoading(false)

            switch result {
            case let .success(items):
                self.appointments = items
                self.tableView.reloadData()
                self.updateEmptyState(isOffline: false)
                self.persist(items)

            case .failure(.unauthorized):
                SessionManager.shared.clearSession()
                self.navigationController?.popToRootViewController(animated: true)

            case let .failure(error):
                self.showFallbackState(error.localizedDescription)
            }
        }
    }

    private func persist(_ items: [PatientAppointment]) {
        guard let patientDNI = SessionManager.shared.patientDNI else { return }
        do {
            try appointmentCache.replace(items, for: patientDNI)
        } catch {
            // La respuesta remota sigue disponible aunque falle la caché local.
        }
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading && appointments.isEmpty {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }

        if !isLoading {
            refreshControl.endRefreshing()
        }
    }

    private func updateEmptyState(isOffline: Bool) {
        retryButton.isHidden = true
        navigationItem.prompt = isOffline && !appointments.isEmpty
            ? "Sin conexión · datos guardados"
            : nil

        if appointments.isEmpty {
            stateLabel.text = "Todavía no tienes citas registradas."
            stateLabel.textColor = .secondaryLabel
            stateLabel.isHidden = false
        } else if isOffline {
            stateLabel.isHidden = true
        } else {
            stateLabel.isHidden = true
        }
    }

    private func showFallbackState(_ message: String) {
        if appointments.isEmpty {
            stateLabel.text = message
            stateLabel.textColor = .systemRed
            stateLabel.isHidden = false
            retryButton.isHidden = false
        } else {
            updateEmptyState(isOffline: true)
        }
    }

    @objc private func refreshAppointments() {
        loadRemoteAppointments()
    }

    @IBAction private func retryButtonTapped(_ sender: UIButton) {
        loadRemoteAppointments()
    }
}

extension AppointmentsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        appointments.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "AppointmentCell",
            for: indexPath
        ) as? AppointmentTableViewCell else {
            assertionFailure("AppointmentCell no está vinculada al Storyboard.")
            return UITableViewCell()
        }

        cell.configure(with: appointments[indexPath.row])
        return cell
    }
}

extension AppointmentsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
