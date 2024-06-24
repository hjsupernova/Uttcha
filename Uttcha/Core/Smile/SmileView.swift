//
//  SmileView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/10.
//

import ContactsUI

import SwiftUI

struct SmileView: View {
    @State private var isShowingSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("친구에게 연락해보세요!")
                    .font(.title2).bold()
                ScrollView(.horizontal) {
                    Button("Button") {
                        isShowingSheet = true
                    }
                }

                Text("소중한 추억")
                    .font(.title2).bold()
            }
            .navigationTitle("Uttcha")
            .sheet(isPresented: $isShowingSheet) {
                ContactList()
            }
        }
    }
}

struct ContactList: View {
    @State private var contacts = [ContactModel]()

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(contacts, id: \.id) { contact in
                Button {
                    CoreDataStack.shared.saveContact(contact)
                } label: {
                    ContactRow(contact: contact)
                }
            }
            .navigationTitle("연락처 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear(perform: getContactList)
    }

    // TODO: MVVM
    private func getContactList() {
        let CNStore = CNContactStore()

        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            DispatchQueue.global(qos: .background).async {
                do {
                    let keys = [
                        CNContactGivenNameKey as CNKeyDescriptor,
                        CNContactFamilyNameKey as CNKeyDescriptor,
                        CNContactImageDataKey as CNKeyDescriptor, // Added image data key
                        CNContactPhoneNumbersKey as CNKeyDescriptor // Added phone numbers key if you want to use it
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
                        let name1 = (contact1.familyName ?? "") + (contact1.givenName ?? "")
                        let name2 = (contact2.familyName ?? "") + (contact2.givenName ?? "")

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
                        contacts = fetchedContacts
                    }

                } catch {
                    print("Error while fetchiing : \(error)")
                }
            }

        case .denied:
            print("denied")

        case .notDetermined:
            print("not determined")
            CNStore.requestAccess(for: .contacts) { granted, error in
                if granted {
                    getContactList()
                } else if let error = error {
                    print("error while requesting permission :\(error)")

                }
            }
        case .restricted:
            print("restred")
        default:
            print("deafult")
        }
    }
}

struct ContactRow: View {
    let contact: ContactModel

    var body: some View {
        HStack {
            if let imageData = contact.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(contact.familyName ?? "" )\(contact.givenName ?? "" )").fontWeight(.semibold)

                Text("\(contact.phoneNumber ?? "")")
                    .font(.caption2 )
                    .foregroundStyle(.gray)
            }.multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    let contact = ContactModel(
        familyName: "현진",
        givenName: "김",
        phoneNumber: "010-0000-0000",
        imageData: nil
    )
    return ContactRow(contact: contact)
}
