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

        guard let imageData = bitmap.jpegData(compressionQuality: 0.5) else { return }

        photo.imageData = imageData
        photo.dateCreated = Date()

        save()
    }

    func fetchTodayPhoto() -> Photo? {
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]  // Latest first
        request.fetchLimit = 1  // Limit to one photo

        let calendar = Calendar.current
        let now = Date()

        // Create start and end of today

        let startOfDay = calendar.startOfDay(for: now)
        guard let endOfDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay) else {
            return nil
        }

        // Create the predicate
        request.predicate = NSPredicate(format: "dateCreated >= %@ AND dateCreated <= %@",
                                        startOfDay as NSDate,
                                        endOfDay as NSDate)

        do {
            let results = try persistentContainer.viewContext.fetch(request)
            return results.first
        } catch {
            return nil
        }
    }

    func fetchPhotos(for monthComponents: DateComponents) -> [Photo] {
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]

        let calendar = Calendar.current

        // Create start and end dates for the month
        guard let startOfMonth = calendar.date(from: monthComponents),
              let startOfNextMonth = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth) else {
            print("Error: Could not create date range")
            return []
        }

        // Create the predicate
        request.predicate = NSPredicate(format: "dateCreated >= %@ AND dateCreated < %@",
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
        guard let photoDate = photo.dateCreated else { return }
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.predicate = NSPredicate(format: "dateCreated == %@", photoDate as CVarArg)

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
        coreDataContact.dateCreated = Date()

        save()
    }

    func fetchSavedContacts() -> [ContactModel] {
        let request = NSFetchRequest<Contact>(entityName: "Contact")
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]

        do {
            let coredataContacts = try persistentContainer.viewContext.fetch(request)
            return coredataContacts.map {
                ContactModel(
                    familyName: $0.familyName ?? "N/A",
                    givenName: $0.givenName ?? "N/A",
                    phoneNumber: $0.phoneNumber ?? "01000000000",
                    imageData: $0.imageData ?? UIImage(systemName: "person.circle.fill")!.pngData()!
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
        guard let jpegData = uiImage.jpegData(compressionQuality: 0.5) else { return }

        let memory = Memory(context: persistentContainer.viewContext)

        // TODO: 여기서 image.dateCreated 등이 생략될 수 있다는 게 문제.. 이걸 컴파일단에서 막아야함..
        memory.imageData = jpegData
        memory.dateCreated = Date()
        memory.memoryId = UUID()

        save()
    }

    func fetchSavedMemories() -> [MemoryModel] {
        let request = NSFetchRequest<Memory>(entityName: "Memory")
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]

        do {
            let memories = try persistentContainer.viewContext.fetch(request)
            return memories.compactMap {
                if let id = $0.memoryId,
                   let imageData = $0.imageData,
                   let date = $0.dateCreated {
                    return MemoryModel(id: id, imageData: imageData, dateCreated: date)
                }
                return nil
            }
        } catch {
            return []
        }
    }

    func removeMemory(_ memory: MemoryModel) {
        let request = NSFetchRequest<Memory>(entityName: "Memory")
        request.predicate = NSPredicate(format: "memoryId == %@", memory.id as CVarArg)

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
