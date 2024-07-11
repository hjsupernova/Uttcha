//
//  main.swift
//  CoreDataDemo
//
//  Created by KHJ on 2024/04/09.
//

import Foundation
import CoreData
import UIKit

class CoreDataStack {
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

// MARK: - Photo

extension CoreDataStack {
    func savePhoto(_ bitmap: UIImage) {
        let photo = Photo(context: persistentContainer.viewContext)

        photo.blob = bitmap.pngData()
        photo.date = Date()

        save()
    }

    func fetchPhotos(for monthComponents: DateComponents) -> [Photo] {
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        let calendar = Calendar.current

        // Create start and end dates for the month
        guard let startOfMonth = calendar.date(from: monthComponents),
              let startOfNextMonth = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth) else {
            print("Error: Could not create date range")
            return []
        }

        // Create the predicate
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                        startOfMonth as NSDate,
                                        startOfNextMonth as NSDate)

        do {
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error fetching photos: \(error)")
            return []
        }
    }

    func removePhoto(_ photo: Photo) {
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.predicate = NSPredicate(format: "date == %@", photo.date! as CVarArg)

        do {
            let photos = try persistentContainer.viewContext.fetch(request)
            for photo in photos {
                persistentContainer.viewContext.delete(photo)
            }

            save()
        } catch {
            print("Failed to fetch contact to remove : \(error)")
        }
    }
}

// MARK: - Contact

extension CoreDataStack {
    func saveContact(_ contact: ContactModel, savedContacts: [ContactModel]) {
        if savedContacts.contains(where: { $0.familyName == contact.familyName && $0.givenName == contact.givenName }) {
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

    func fetchSavedContacts() -> [ContactModel] {
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

        if let jpegData = uiImage.jpegData(compressionQuality: 0.5) {
            image.blob = jpegData
            print("jpeg: \(jpegData.count)")
        }

        image.date = Date()
        image.memoryId = UUID()

        save()
    }

    func fetchSavedMemories() -> [MemoryModel] {
        let request = NSFetchRequest<Memory>(entityName: "Memory")

        do {
            let memories = try persistentContainer.viewContext.fetch(request)
            return memories.sorted { $0.date! < $1.date! }.map {
                MemoryModel(
                    id: $0.memoryId!,
                    image: $0.blob!,
                    date: $0.date!
                )
            }
        } catch {
            return []
        }
    }

    func removeMemory(_ memory: MemoryModel) {
        let request = NSFetchRequest<Memory>(entityName: "Memory")
        request.predicate = NSPredicate(format: "memoryId == %@", memory.id! as CVarArg)

        do {
            let memories = try persistentContainer.viewContext.fetch(request)

            for memory in memories {
                persistentContainer.viewContext.delete(memory)

            }
            save()
        } catch {
            print("Failed to fetch contact to remove : \(error)")
        }
    }
}

struct MemoryModel: Identifiable {
    let id: UUID?
    let image: Data
    let date: Date
}

// MARK: - Mock Data

func createMockDates() -> [Date] {
    let calendar = Calendar.current
    var mockDates: [Date] = []

    // Get the current date
    let now = Date()

    // Create dates for the current month
    mockDates.append(contentsOf: createRandomDates(for: now, count: 10))

    // Create dates for the past 4 months
    for i in 1...4 {
        guard let pastDate = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
        mockDates.append(contentsOf: createRandomDates(for: pastDate, count: 10))
    }

    return mockDates
}

private func createRandomDates(for baseDate: Date, count: Int) -> [Date] {
    let calendar = Calendar.current
    let range = calendar.range(of: .day, in: .month, for: baseDate)!

    var dates: [Date] = []

    for _ in 0..<count {
        let randomDay = Int.random(in: range)
        if let date = calendar.date(bySetting: .day, value: randomDay, of: baseDate) {
            dates.append(date)
        }
    }

    return dates
}
