//
//  SmileView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/10.
//

import ContactsUI

import SwiftUI

struct SmileView: View {
    @StateObject private var smileViewModel = SmileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HeaderView(label: "친구에게 연락해보세요!")

                    ContactListView(
                        contacts: smileViewModel.contactSavedList,
                        addContactAction: {
                            smileViewModel.perform(action: .contactAddButtonTapped)
                        },
                        longPressAction: { contact in
                            smileViewModel.perform(action: .contactLongTapped(contact))
                        }
                    )
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    HeaderView(label: "소중한 추억!")
                }
                .padding(.horizontal)
            }
            .navigationTitle("Uttcha")
            .sheet(isPresented: $smileViewModel.isShowingContactSheet) {
                ContactListSheet(smileViewModel: smileViewModel)
            }
            .confirmationDialog("삭제하기", isPresented: $smileViewModel.isShowingContactRemoveConfirmationDialog) {
                Button("연락처 삭제", role: .destructive) {
                    smileViewModel.perform(action: .contactRemoveButtonTapped)
                }
            }
        }
    }
}

// MARK: - Contacts

struct ContactListView: View {
    let contacts: [ContactModel]
    let addContactAction: () -> Void
    let longPressAction: (ContactModel) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if contacts.isEmpty {
                    AddContactButton(action: addContactAction)
                } else {
                    ForEach(contacts) { contact in
                        ContactButton(
                            contact: contact,
                            longPressAction: longPressAction
                        )
                    }

                    AddContactButton(action: addContactAction)
                }
            }
        }
    }
}

struct AddContactButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10]))
                    .frame(width: 150, height: 200)

                Image(systemName: "plus")
                    .font(.title).bold()
            }
            .foregroundStyle(Color(uiColor: .systemGray6))
        }
    }
}

struct ContactButton: View {
    let contact: ContactModel
    let longPressAction: (ContactModel) -> Void

    var body: some View {
        Link(destination: URL(string: "tel:\(contact.phoneNumber ?? "00000000000")")!) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 150, height: 200)
                    .foregroundStyle(Color(uiColor: .systemGray6))

                VStack {
                    if let imageData = contact.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }

                    Text(contact.familyName + contact.givenName)
                }
            }

        }
        .supportsLongPress {
            longPressAction(contact)
        }
    }
}

struct ContactListSheet: View {
    @ObservedObject var smileViewModel: SmileViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(smileViewModel.contacts, id: \.id) { contact in
                Button {
                    smileViewModel.perform(action: .contactListRowTapped(contact))

                    dismiss()
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
        .onAppear {
            smileViewModel.perform(action: .contactListViewAppeared)
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

struct HeaderView: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.title2)
            .bold()
    }
}

#Preview {
    SmileView()
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
