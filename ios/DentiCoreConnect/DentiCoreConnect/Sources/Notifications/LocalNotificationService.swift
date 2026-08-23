import Foundation
@preconcurrency import UserNotifications

protocol AppointmentNotificationScheduling {
    func requestAuthorization(
        completion: @escaping (Bool) -> Void
    )
    func synchronizeIfAuthorized(_ appointments: [PatientAppointment])
    func scheduleReminders(for appointment: PatientAppointment)
    func removeReminders(forAppointmentID appointmentID: Int)
}

final class LocalNotificationService: AppointmentNotificationScheduling {
    static let shared = LocalNotificationService()

    private let notificationCenter: UNUserNotificationCenter
    private let identifierPrefix = "denticore.appointment"
    private let activeStates = Set(["PENDIENTE", "CONFIRMADA"])

    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    func requestAuthorization(
        completion: @escaping (Bool) -> Void
    ) {
        notificationCenter.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                self.completeOnMain(true, completion: completion)

            case .notDetermined:
                self.notificationCenter.requestAuthorization(
                    options: [.alert, .badge, .sound]
                ) { granted, _ in
                    self.completeOnMain(granted, completion: completion)
                }

            case .denied:
                self.completeOnMain(false, completion: completion)

            @unknown default:
                self.completeOnMain(false, completion: completion)
            }
        }
    }

    func synchronizeIfAuthorized(_ appointments: [PatientAppointment]) {
        notificationCenter.getNotificationSettings { [weak self] settings in
            guard
                let self,
                [.authorized, .provisional, .ephemeral]
                    .contains(settings.authorizationStatus)
            else {
                return
            }

            appointments.forEach { appointment in
                if self.isActive(appointment) {
                    self.scheduleReminders(for: appointment)
                } else {
                    self.removeReminders(forAppointmentID: appointment.id)
                }
            }
        }
    }

    func scheduleReminders(for appointment: PatientAppointment) {
        removeReminders(forAppointmentID: appointment.id)

        guard
            isActive(appointment),
            let appointmentDate = AppointmentPresentation.date(
                from: appointment.fechaHora
            )
        else {
            return
        }

        let reminders: [(suffix: String, interval: TimeInterval, title: String)] = [
            ("24h", 24 * 60 * 60, "Tu cita dental es mañana"),
            ("2h", 2 * 60 * 60, "Tu cita dental es en 2 horas")
        ]

        reminders.forEach { reminder in
            let reminderDate = appointmentDate.addingTimeInterval(-reminder.interval)
            guard reminderDate.timeIntervalSinceNow > 60 else { return }

            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = "\(appointment.servicioNombre) con \(appointment.odontologoNombre)."
            content.sound = .default
            content.userInfo = ["appointmentId": appointment.id]

            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "America/Lima") ?? .current
            var components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminderDate
            )
            components.timeZone = calendar.timeZone

            let request = UNNotificationRequest(
                identifier: identifier(
                    appointmentID: appointment.id,
                    suffix: reminder.suffix
                ),
                content: content,
                trigger: UNCalendarNotificationTrigger(
                    dateMatching: components,
                    repeats: false
                )
            )
            notificationCenter.add(request)
        }

        scheduleSameDayReminder(
            for: appointment,
            appointmentDate: appointmentDate
        )
    }

    func removeReminders(forAppointmentID appointmentID: Int) {
        let identifiers = ["24h", "2h", "same-day"].map {
            identifier(appointmentID: appointmentID, suffix: $0)
        }
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
        notificationCenter.removeDeliveredNotifications(
            withIdentifiers: identifiers
        )
    }

    private func isActive(_ appointment: PatientAppointment) -> Bool {
        activeStates.contains(appointment.estado.uppercased())
    }

    private func scheduleSameDayReminder(
        for appointment: PatientAppointment,
        appointmentDate: Date
    ) {
        let remaining = appointmentDate.timeIntervalSinceNow
        guard remaining > 90, remaining <= 2 * 60 * 60 else { return }

        let leadTime: TimeInterval
        let title: String
        if remaining > 6 * 60 {
            leadTime = 5 * 60
            title = "Tu cita dental comienza en 5 minutos"
        } else {
            leadTime = 60
            title = "Tu cita dental está por comenzar"
        }

        let reminderDate = appointmentDate.addingTimeInterval(-leadTime)
        guard reminderDate.timeIntervalSinceNow > 15 else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "\(appointment.servicioNombre) con \(appointment.odontologoNombre)."
        content.sound = .default
        content.userInfo = ["appointmentId": appointment.id]

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Lima") ?? .current
        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: reminderDate
        )
        components.timeZone = calendar.timeZone

        notificationCenter.add(
            UNNotificationRequest(
                identifier: identifier(
                    appointmentID: appointment.id,
                    suffix: "same-day"
                ),
                content: content,
                trigger: UNCalendarNotificationTrigger(
                    dateMatching: components,
                    repeats: false
                )
            )
        )
    }

    private func identifier(appointmentID: Int, suffix: String) -> String {
        "\(identifierPrefix).\(appointmentID).\(suffix)"
    }

    private func completeOnMain(
        _ value: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        DispatchQueue.main.async {
            completion(value)
        }
    }
}
