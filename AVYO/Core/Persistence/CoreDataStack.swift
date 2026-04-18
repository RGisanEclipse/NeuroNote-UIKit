//
//  CoreDataStack.swift
//  AVYO
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "NeuroNote_UIKit")
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                Logger.shared.error("CoreData failed to load", fields: ["error": error.localizedDescription])
            }
        }
    }

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            Logger.shared.error("CoreData save failed", fields: ["error": error.localizedDescription])
        }
    }
}
