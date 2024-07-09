//
//  SmileViewModel.swift
//  Uttcha
//
//  Created by KHJ on 6/24/24.
//

import Contacts
import Foundation
import UIKit

enum SmileViewModelAction {

    // Contacts
    case contactAddButtonTapped
    case contactListRowTapped(ContactModel)
    case contactListViewAppeared
    case contactLongTapped(ContactModel)
    case contactRemoveButtonTapped

    // Images
    case imageAddButtonTapped
    case imageLongPressed(MemoryModel)
    case imageRemoveButtonTapped
    case imageTapped(MemoryModel)
}

class SmileViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var isShowingContactSheet: Bool = false
    @Published var contactSavedList: [ContactModel] = []
    @Published var contacts: [ContactModel] = []
    @Published var isShowingContactRemoveConfirmationDialog: Bool = false
    @Published var isShowingUIImagePicker: Bool = false
    @Published var memoryList: [MemoryModel] = []
    @Published var isShowingMemoryRemoveConfirmationDialog: Bool = false
    @Published var isShowingContactAuthorizationAlert: Bool = false
    @Published var tappedMemory: MemoryModel?

    // MARK: - Public properties
    var longTappedContact: ContactModel?
    var longPressedMemory: MemoryModel? 

    init() {
        getContactSavedList()
        getMemorySavedList()
    }
    // MARK: - Actions
    func perform(action: SmileViewModelAction) {
        switch action {
        // contacts
        case .contactAddButtonTapped:
            showContactSheet()
        case .contactListRowTapped(let contact):
            saveTappedContact(contact)
        case .contactListViewAppeared:
            getContactList()
        case .contactLongTapped(let contact):
            showContactRemoveActionSheet(contact)
        case .contactRemoveButtonTapped:
            removeLongTappedContact()

        // images
        case .imageAddButtonTapped:
            showUIImagePicker()
        case .imageLongPressed(let memory):
            showMemoryRemoveActionSheet(memory)
        case .imageRemoveButtonTapped:
            removeLongPressedMemory()
        case .imageTapped(let memory):
            showMemoryDetailView(memory)
        }
    }

    // MARK: - Action Handlers
    private func showContactSheet() {
        isShowingContactSheet = true
    }

    private func saveTappedContact(_ contact: ContactModel) {
        CoreDataStack.shared.saveContact(contact, contactSavedList: contactSavedList)

        getContactSavedList()
    }

    private func getContactList() {
        let CNStore = CNContactStore()

        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let keys = [
                        CNContactGivenNameKey as CNKeyDescriptor,
                        CNContactFamilyNameKey as CNKeyDescriptor,
                        CNContactImageDataKey as CNKeyDescriptor,
                        CNContactPhoneNumbersKey as CNKeyDescriptor
                    ]
                    let request = CNContactFetchRequest(keysToFetch: keys)

                    var fetchedContacts = [ContactModel]()

                    try CNStore.enumerateContacts(with: request) { cnContact, _ in
                        let contact = ContactModel(
                            familyName: cnContact.familyName,
                            givenName: cnContact.givenName,
                            phoneNumber: cnContact.phoneNumbers.first?.value.stringValue,
                            imageData: cnContact.imageData
                        )

                        fetchedContacts.append(contact)
                    }
                    
                    fetchedContacts.sort { contact1, contact2 in
                        let name1 = (contact1.familyName) + (contact1.givenName)
                        let name2 = (contact2.familyName) + (contact2.givenName)

                        guard let firstChar1 = name1.first, let firstChar2 = name2.first else {
                            // If one or both names are empty, handle the comparison (e.g., empty names come first)
                            return name1 < name2
                        }

                        if firstChar1 >= "가" && firstChar1 <= "힣" && firstChar2 >= "가" && firstChar2 <= "힣" {
                            return name1 < name2 // Korean sort
                        } else if (firstChar1 >= "a" && firstChar1 <= "z" || firstChar1 >= "A" && firstChar1 <= "Z") &&
                                    (firstChar2 >= "a" && firstChar2 <= "z" || firstChar2 >= "A" && firstChar2 <= "Z") {
                            return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending // English sort
                        } else {
                            // Korean comes before English
                            return firstChar1 >= "가" && firstChar1 <= "힣"
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.contacts = fetchedContacts
                    }
                } catch {
                    print("Error while fetchiing : \(error)")
                }
            }
        case .notDetermined:
            CNStore.requestAccess(for: .contacts) { granted, error in
                if granted {
                    self.getContactList()
                } else if let error = error {
                    print("error while requesting permission :\(error)")
                }
            }
        case .restricted:
            print("restred")
        case .denied:
            showContactAuthorizationAlert()
        default:
            print("default")
        }
    }

    private func showContactRemoveActionSheet(_ contact: ContactModel) {
        longTappedContact = contact
        isShowingContactRemoveConfirmationDialog = true

    }

    private func removeLongTappedContact() {
        if let longTappedContact = longTappedContact {
            CoreDataStack.shared.removeContact(longTappedContact)

            getContactSavedList()
        }
    }

    private func showUIImagePicker() {
        isShowingUIImagePicker = true
    }

    private func showMemoryRemoveActionSheet(_ memory: MemoryModel) {
        longPressedMemory = memory
        isShowingMemoryRemoveConfirmationDialog = true
    }

    private func removeLongPressedMemory() {
        if let longPressedMemory = longPressedMemory {
            CoreDataStack.shared.removeMemory(longPressedMemory)

            getMemorySavedList()
        }
    }

    private func showMemoryDetailView(_ memory: MemoryModel) {
        tappedMemory = memory
    }
}

// MARK: - Private instance methods

extension SmileViewModel {
    private func getContactSavedList() {
        contactSavedList = CoreDataStack.shared.getContactSavedList()
    }

    private func getMemorySavedList() {
        memoryList = CoreDataStack.shared.getSavedMemoryList()
    }

    private func showContactAuthorizationAlert() {
        isShowingContactAuthorizationAlert = true
    }
}
