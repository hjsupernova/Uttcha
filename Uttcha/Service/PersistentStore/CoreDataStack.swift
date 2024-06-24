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
    func saveContact(_ contact: ContactModel) {
        var coreDataContact = Contact(context: persistentContainer.viewContext)
        coreDataContact.familyName = contact.familyName
        coreDataContact.givenName = contact.givenName
        coreDataContact.phoneNumber = contact.phoneNumber
        coreDataContact.imageData = contact.imageData

        save()
    }

    func getContactList() -> [ContactModel] {
        let request = NSFetchRequest<Contact>(entityName: "Contact")
        
        do {
            let coredataContacts = try persistentContainer.viewContext.fetch(request)
            return coredataContacts.map {
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
}

// MARK: - UIImage

extension UIImage {

    func toData() -> Data? {
        return pngData()
    }

    var sizeInBytes: Int {
        if let data = toData() {
            return data.count
        } else {
            return 0
        }
    }

    var sizeInMB: Double {
        return Double(sizeInBytes) / 1_000_000
    }
}
