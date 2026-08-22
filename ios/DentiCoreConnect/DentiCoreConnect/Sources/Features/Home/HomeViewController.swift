import UIKit

final class HomeViewController: UIViewController {
    private enum Section: Int, CaseIterable {
        case patient
        case clinic
        case specialties
        case services

        var title: String? {
            switch self {
            case .patient:
                return nil
            case .clinic:
                return "Clínica"
            case .specialties:
                return "Especialidades"
            case .services:
                return "Servicios disponibles"
            }
        }
    }

    private let patientService: PatientServicing
    private let catalogService: CatalogServicing

    private var patient: PatientProfile?
    private var specialties: [Specialty] = []
    private var services: [DentalService] = []
    private var selectedSpecialtyID: Int?
    private var hasLoadedContent = false

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.cellIdentifier
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.backgroundColor = .systemGroupedBackground
        tableView.refreshControl = refreshControl
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        return control
    }()

    private let stateStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = DentiCoreTheme.primary
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let stateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 34)
        imageView.isHidden = true
        return imageView
    }()

    private let stateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Reintentar"
        configuration.baseBackgroundColor = DentiCoreTheme.primary
        configuration.cornerStyle = .medium

        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(retryLoading), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private static let cellIdentifier = "HomeCell"

    init(
        patientService: PatientServicing = PatientService(),
        catalogService: CatalogServicing = CatalogService()
    ) {
        self.patientService = patientService
        self.catalogService = catalogService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        patientService = PatientService()
        catalogService = CatalogService()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        loadContent()
    }

    private func configureInterface() {
        title = "Inicio"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain,
            target: self,
            action: #selector(confirmLogout)
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Cerrar sesión"

        stateStackView.addArrangedSubview(activityIndicator)
        stateStackView.addArrangedSubview(stateImageView)
        stateStackView.addArrangedSubview(stateLabel)
        stateStackView.addArrangedSubview(retryButton)

        view.addSubview(tableView)
        view.addSubview(stateStackView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stateStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 32
            ),
            stateStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -32
            )
        ])
    }

    private func loadContent() {
        showLoadingState()

        let group = DispatchGroup()
        var loadedPatient: PatientProfile?
        var loadedSpecialties: [Specialty]?
        var loadedServices: [DentalService]?
        var firstError: APIError?

        group.enter()
        patientService.fetchCurrentPatient { result in
            switch result {
            case let .success(profile):
                loadedPatient = profile
            case let .failure(error):
                firstError = firstError ?? error
            }
            group.leave()
        }

        group.enter()
        catalogService.fetchSpecialties { result in
            switch result {
            case let .success(items):
                loadedSpecialties = items
            case let .failure(error):
                firstError = firstError ?? error
            }
            group.leave()
        }

        group.enter()
        catalogService.fetchServices(specialtyID: nil) { result in
            switch result {
            case let .success(items):
                loadedServices = items.filter { $0.activo != false }
            case let .failure(error):
                firstError = firstError ?? error
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.refreshControl.endRefreshing()

            if case .unauthorized? = firstError {
                self.handleExpiredSession()
                return
            }

            guard
                let loadedPatient,
                let loadedSpecialties,
                let loadedServices
            else {
                self.showErrorState(
                    firstError?.localizedDescription
                        ?? "No fue posible cargar la información."
                )
                return
            }

            self.patient = loadedPatient
            self.specialties = loadedSpecialties
            self.services = loadedServices
            self.hasLoadedContent = true
            self.title = "Hola, \(loadedPatient.firstName)"
            self.showContent()
        }
    }

    private var visibleServices: [DentalService] {
        guard let selectedSpecialtyID else {
            return services
        }
        return services.filter { $0.especialidadId == selectedSpecialtyID }
    }

    private func showLoadingState() {
        if !hasLoadedContent {
            tableView.isHidden = true
            stateStackView.isHidden = false
            stateImageView.isHidden = true
            stateLabel.text = "Cargando tu información…"
            retryButton.isHidden = true
            activityIndicator.startAnimating()
        }
    }

    private func showContent() {
        activityIndicator.stopAnimating()
        stateStackView.isHidden = true
        tableView.isHidden = false
        tableView.reloadData()
    }

    private func showErrorState(_ message: String) {
        activityIndicator.stopAnimating()

        if hasLoadedContent {
            tableView.isHidden = false
            presentMessage(title: "No se pudo actualizar", message: message)
            return
        }

        tableView.isHidden = true
        stateStackView.isHidden = false
        stateImageView.image = UIImage(systemName: "wifi.exclamationmark")
        stateImageView.isHidden = false
        stateLabel.text = message
        retryButton.isHidden = false
    }

    private func handleExpiredSession() {
        SessionManager.shared.clearSession()
        presentMessage(
            title: "Sesión finalizada",
            message: "Vuelve a iniciar sesión para continuar."
        ) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }

    private func presentMessage(
        title: String,
        message: String,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    @objc private func refreshContent() {
        loadContent()
    }

    @objc private func retryLoading() {
        loadContent()
    }

    @objc private func confirmLogout() {
        let alert = UIAlertController(
            title: "Cerrar sesión",
            message: "¿Deseas salir de DentiCore Connect?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cerrar sesión", style: .destructive) { [weak self] _ in
            SessionManager.shared.clearSession()
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .patient, .clinic:
            return patient == nil ? 0 : 1
        case .specialties:
            return specialties.count
        case .services:
            return visibleServices.count
        }
    }

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        Section(rawValue: section)?.title
    }

    func tableView(
        _ tableView: UITableView,
        titleForFooterInSection section: Int
    ) -> String? {
        guard Section(rawValue: section) == .specialties else { return nil }
        return selectedSpecialtyID == nil
            ? "Selecciona una especialidad para filtrar los servicios."
            : "Toca nuevamente la especialidad seleccionada para mostrar todos."
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.cellIdentifier,
            for: indexPath
        )
        var content = UIListContentConfiguration.subtitleCell()
        content.imageProperties.tintColor = DentiCoreTheme.primary
        content.imageProperties.maximumSize = CGSize(width: 30, height: 30)

        guard let section = Section(rawValue: indexPath.section) else {
            return cell
        }

        switch section {
        case .patient:
            content.image = UIImage(systemName: "person.crop.circle.fill")
            content.text = patient?.fullName
            let email = patient?.correo?.isEmpty == false ? " · \(patient?.correo ?? "")" : ""
            content.secondaryText = "DNI \(patient?.dni ?? "")\(email)"
            cell.selectionStyle = .none
            cell.accessoryType = .none

        case .clinic:
            content.image = UIImage(systemName: "cross.case.fill")
            content.text = patient?.clinica.nombreComercial
            content.secondaryText = "Zona horaria: \(patient?.clinica.zonaHoraria ?? "America/Lima")"
            cell.selectionStyle = .none
            cell.accessoryType = .none

        case .specialties:
            let specialty = specialties[indexPath.row]
            content.image = UIImage(systemName: "stethoscope")
            content.text = specialty.nombre
            content.secondaryText = "Explorar servicios"
            cell.selectionStyle = .default
            cell.accessoryType = selectedSpecialtyID == specialty.id ? .checkmark : .disclosureIndicator

        case .services:
            let service = visibleServices[indexPath.row]
            content.image = UIImage(systemName: "tooth.fill")
            content.text = service.nombre
            content.secondaryText = serviceSummary(service)
            cell.selectionStyle = .none
            cell.accessoryType = .none
        }

        cell.contentConfiguration = content
        return cell
    }

    private func serviceSummary(_ service: DentalService) -> String {
        var details: [String] = []

        if let code = service.codigo, !code.isEmpty {
            details.append(code)
        }
        if let duration = service.duracionMinutos {
            details.append("\(duration) min")
        }
        if let price = service.costoReferencial {
            details.append(String(format: "S/ %.2f", price))
        }

        return details.joined(separator: " · ")
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard Section(rawValue: indexPath.section) == .specialties else { return }

        let specialty = specialties[indexPath.row]
        selectedSpecialtyID = selectedSpecialtyID == specialty.id ? nil : specialty.id
        tableView.reloadSections(
            IndexSet(integer: Section.specialties.rawValue),
            with: .none
        )
        tableView.reloadSections(
            IndexSet(integer: Section.services.rawValue),
            with: .automatic
        )
    }
}
