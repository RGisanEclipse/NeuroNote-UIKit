//
//  CoreDataStack.swift
//  NeuroNote-UIKit
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "NeuroNote_UIKit")
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData failed to load: \(error)")
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
