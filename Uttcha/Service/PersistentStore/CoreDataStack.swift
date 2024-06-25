//
//  main.swift
//  CoreDataDemo
//
//  Created by KHJ on 2024/04/09.
//

import Foundation
import CoreData
import UIKit

class CoreDataStack: ObservableObject {
    @Published var imageList: [Photo] = []

    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Model")

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()

    private init() { }
}

extension CoreDataStack {
    func save() {
        guard persistentContainer.viewContext.hasChanges else { return }

        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to save the context:", error.localizedDescription)

        }
    }
}

// MARK: - Image

extension CoreDataStack {
    func saveImage(_ bitmap: UIImage) {
        let image = Photo(context: persistentContainer.viewContext)

        image.blob = bitmap.toData()
        image.date = Date()

        save()
    }

    func getImageList() {
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            imageList = try persistentContainer.viewContext.fetch(request)
        } catch {
            // TODO: throw error
        }
    }
}

// MARK: - Contact

extension CoreDataStack {
    func saveContact(_ contact: ContactModel, contactSavedList: [ContactModel]) {
        if contactSavedList.contains(where: { $0.familyName == contact.familyName && $0.givenName == contact.givenName }) {
            return
        }

        var coreDataContact = Contact(context: persistentContainer.viewContext)
        coreDataContact.familyName = contact.familyName
        coreDataContact.givenName = contact.givenName
        coreDataContact.phoneNumber = contact.phoneNumber
        coreDataContact.imageData = contact.imageData
        coreDataContact.date = Date()

        save()
    }

    func getContactSavedList() -> [ContactModel] {
        let request = NSFetchRequest<Contact>(entityName: "Contact")

        do {
            let coredataContacts = try persistentContainer.viewContext.fetch(request)
            return coredataContacts.sorted { $0.date! < $1.date! }.map {
                ContactModel(
                    familyName: $0.familyName ?? "",
                    givenName: $0.givenName ?? "",
                    phoneNumber: $0.phoneNumber,
                    imageData: $0.imageData
                )
            }
        } catch {
            return []
        }
    }

    func removeContact(_ contact: ContactModel) {
        let request = NSFetchRequest<Contact>(entityName: "Contact")
        request.predicate = NSPredicate(format: "familyName == %@ AND givenName == %@", contact.familyName, contact.givenName)

        do {
            let coreDataContacts = try persistentContainer.viewContext.fetch(request)
            for coreDataContact in coreDataContacts {
                persistentContainer.viewContext.delete(coreDataContact)
            }

            save()
        } catch {
            print("Failed to fetch contact to remove : \(error)")
        }
    }
}

// MARK: - Memory

extension CoreDataStack {
    func saveMemory(_ uiImage: UIImage) {
        let image = Memory(context: persistentContainer.viewContext)

        image.blob = uiImage.toData()
        image.date = Date()

        save()
    }

    func getSavedMemoryList() -> [MemoryModel] {
        let request = NSFetchRequest<Memory>(entityName: "Memory")

        do {
            let coredataMemoryList = try persistentContainer.viewContext.fetch(request)
            return coredataMemoryList.sorted { $0.date! < $1.date! }.map {
                MemoryModel(
                    image: $0.blob!,
                    date: $0.date!
                )
            }
        } catch {
            return []
        }
    }
}

struct MemoryModel: Identifiable {
    let id = UUID()
    let image: Data
    let date: Date
}
// MARK: - UIImage

extension UIImage {

    func toData() -> Data? {
        return pngData()
    }
}
