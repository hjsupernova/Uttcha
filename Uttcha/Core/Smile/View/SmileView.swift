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
                    Text("친구에게 연락해보세요!")
                        .font(.title2)
                        .bold()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if smileViewModel.contactSavedList.isEmpty {
                                Button {
                                    smileViewModel.perform(action: .contactAddButtonTapped)
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10]))
                                            .frame(width: 150, height: 200)

                                        Image(systemName: "plus")
                                            .font(.title).bold()
                                    }
                                    .foregroundStyle(Color(uiColor: .systemGray6))
                                }
                            } else {
                                ForEach(smileViewModel.contactSavedList) { contact in

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
                                }

                                Button {
                                    smileViewModel.perform(action: .contactAddButtonTapped)
                                } label: {
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
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("소중한 추억")
                        .font(.title2).bold()
                }
                .padding(.horizontal)

            }
            .navigationTitle("Uttcha")
            .sheet(isPresented: $smileViewModel.isShowingContactSheet) {
                ContactListView(smileViewModel: smileViewModel)
            }
        }
    }
}

struct ContactListView: View {
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
