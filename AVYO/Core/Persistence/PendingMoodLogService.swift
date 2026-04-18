//
//  PendingMoodLogService.swift
//  AVYO
//

import CoreData

struct PendingMoodLogEntry {
    let objectID: NSManagedObjectID
    let mood: String
    let reason: String?
    let loggedAt: Date
}

final class PendingMoodLogService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    func enqueue(_ data: MoodLogData) {
        let entity = NSEntityDescription.entity(forEntityName: "PendingMoodLog", in: context)!
        let object = NSManagedObject(entity: entity, insertInto: context)
        object.setValue(UUID(), forKey: "id")
        object.setValue(data.mood, forKey: "mood")
        object.setValue(data.reason, forKey: "reason")
        object.setValue(Date(), forKey: "loggedAt")
        CoreDataStack.shared.save()
    }

    func fetchAll() -> [PendingMoodLogEntry] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "PendingMoodLog")
        request.sortDescriptors = [NSSortDescriptor(key: "loggedAt", ascending: true)]
        return ((try? context.fetch(request)) ?? []).compactMap { object in
            guard let mood = object.value(forKey: "mood") as? String,
                  let loggedAt = object.value(forKey: "loggedAt") as? Date else { return nil }
            let reason = object.value(forKey: "reason") as? String
            return PendingMoodLogEntry(
                objectID: object.objectID,
                mood: mood,
                reason: reason,
                loggedAt: loggedAt
            )
        }
    }

    func delete(objectID: NSManagedObjectID) {
        guard let object = try? context.existingObject(with: objectID) else { return }
        context.delete(object)
        CoreDataStack.shared.save()
    }

    func hasPending() -> Bool {
        let request = NSFetchRequest<NSManagedObject>(entityName: "PendingMoodLog")
        return (try? context.count(for: request)) ?? 0 > 0
    }
}
