//
//  DashboardCacheService.swift
//  AVYO
//

import CoreData

final class DashboardCacheService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    func save(_ payload: DashboardPayload) {
        guard let data = try? JSONEncoder().encode(payload) else { return }

        let request = NSFetchRequest<NSManagedObject>(entityName: "CachedDashboard")
        let existing = (try? context.fetch(request)) ?? []
        existing.forEach { context.delete($0) }

        let entity = NSEntityDescription.entity(forEntityName: "CachedDashboard", in: context)!
        let object = NSManagedObject(entity: entity, insertInto: context)
        object.setValue(data, forKey: "data")
        object.setValue(Date(), forKey: "cachedAt")

        CoreDataStack.shared.save()
    }

    func load() -> DashboardPayload? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CachedDashboard")
        request.fetchLimit = 1
        guard let object = try? context.fetch(request).first,
              let data = object.value(forKey: "data") as? Data else { return nil }
        return try? JSONDecoder().decode(DashboardPayload.self, from: data)
    }
}
