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
    @State private var contacts = [CNContact]()

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(contacts, id: \.identifier) { contactDetail in
                ContactRow(contactDetail: contactDetail)
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

                    var fetchedContacts = [CNContact]()
                    try CNStore.enumerateContacts(with: request) { contact, _ in
                        DispatchQueue.main.async {
                            contacts.append(contact)
                        }
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
    let contactDetail: CNContact

    var body: some View {
        HStack {
            if let imageData = contactDetail.imageData, let uiImage = UIImage(data: imageData) {
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
                Text("\(contactDetail.familyName)\(contactDetail.givenName)").fontWeight(.semibold)

                Text("\(contactDetail.phoneNumbers.first?.value.stringValue ?? "")")
                    .font(.caption2 )
                    .foregroundStyle(.gray)
            }.multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    let contact = CNMutableContact()

    contact.givenName = "현진"
    contact.familyName = "김"

    contact.phoneNumbers = [ CNLabeledValue(
        label: CNLabelPhoneNumberMain,
        value: CNPhoneNumber(stringValue: "010-2181-2611")
    )

    ]
    return ContactRow(contactDetail: contact)
}
