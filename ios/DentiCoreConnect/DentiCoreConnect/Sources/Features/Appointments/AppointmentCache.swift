import CoreData
import UIKit

final class AppointmentCache {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext? = nil) {
        if let context {
            self.context = context
        } else if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.context = appDelegate.persistentContainer.viewContext
        } else {
            self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
    }

    func fetch(for patientDNI: String) throws -> [PatientAppointment] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CachedAppointment")
        request.predicate = NSPredicate(format: "patientDNI == %@", patientDNI)
        request.sortDescriptors = [
            NSSortDescriptor(key: "fechaHora", ascending: false)
        ]

        return try context.fetch(request).compactMap(mapManagedObject)
    }

    func replace(_ appointments: [PatientAppointment], for patientDNI: String) throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CachedAppointment")
        request.predicate = NSPredicate(format: "patientDNI == %@", patientDNI)
        try context.fetch(request).forEach(context.delete)

        let syncedAt = Date()
        for appointment in appointments {
            let object = NSEntityDescription.insertNewObject(
                forEntityName: "CachedAppointment",
                into: context
            )
            object.setValue(Int64(appointment.id), forKey: "id")
            object.setValue(appointment.estado, forKey: "estado")
            object.setValue(appointment.fechaHora, forKey: "fechaHora")
            object.setValue(appointment.fechaHoraFin, forKey: "fechaHoraFin")
            object.setValue(appointment.odontologoNombre, forKey: "odontologoNombre")
            object.setValue(appointment.servicioNombre, forKey: "servicioNombre")
            object.setValue(appointment.especialidadNombre, forKey: "especialidadNombre")
            object.setValue(appointment.sedeNombre, forKey: "sedeNombre")
            object.setValue(appointment.notaPaciente, forKey: "notaPaciente")
            object.setValue(patientDNI, forKey: "patientDNI")
            object.setValue(syncedAt, forKey: "syncedAt")
        }

        if context.hasChanges {
            try context.save()
        }
    }

    private func mapManagedObject(_ object: NSManagedObject) -> PatientAppointment? {
        guard
            let estado = object.value(forKey: "estado") as? String,
            let fechaHora = object.value(forKey: "fechaHora") as? String,
            let fechaHoraFin = object.value(forKey: "fechaHoraFin") as? String,
            let odontologoNombre = object.value(forKey: "odontologoNombre") as? String,
            let servicioNombre = object.value(forKey: "servicioNombre") as? String,
            let sedeNombre = object.value(forKey: "sedeNombre") as? String
        else {
            return nil
        }

        return PatientAppointment(
            id: (object.value(forKey: "id") as? NSNumber)?.intValue ?? 0,
            estado: estado,
            fechaHora: fechaHora,
            fechaHoraFin: fechaHoraFin,
            odontologoNombre: odontologoNombre,
            servicioNombre: servicioNombre,
            especialidadNombre: object.value(forKey: "especialidadNombre") as? String,
            sedeNombre: sedeNombre,
            notaPaciente: object.value(forKey: "notaPaciente") as? String,
            mensaje: nil
        )
    }
}
