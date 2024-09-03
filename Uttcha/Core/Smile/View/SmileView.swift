//
//  SmileView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/10.
//

import SwiftUI

import Kingfisher

struct SmileView: View {
    @StateObject private var smileViewModel = SmileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HeaderView(label: String(localized: "Contacts") )

                        ContactListView(smileViewModel: smileViewModel)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HeaderView(label: String(localized: "Memories"))

                        MemoryListView(smileViewModel: smileViewModel)
                    }
                }
                .padding(.horizontal)

            }
            .navigationTitle("Uttcha")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $smileViewModel.presentedSheet) { sheet in
                switch sheet {
                case .contacts:
                    ContactListSheet(smileViewModel: smileViewModel)
                case .imagePicker:
                    UIImagePicker(smileViewModel: smileViewModel)
                }
            }
            .confirmationDialog("Delete", isPresented: $smileViewModel.isShowingContactRemoveConfirmationDialog) {
                Button("Delete Contact", role: .destructive) {
                    withAnimation {
                        smileViewModel.perform(action: .contactRemoveButtonTapped)
                    }
                }
            }
            .confirmationDialog("Delete", isPresented: $smileViewModel.isShowingMemoryRemoveConfirmationDialog) {
                Button("Delete Memory", role: .destructive) {
                    withAnimation {
                        smileViewModel.perform(action: .memoryRemoveButtonTapped)
                    }
                }
            }
        }
    }
}

// MARK: - Memories

struct MemoryListView: View {
    @ObservedObject var smileViewModel: SmileViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                if smileViewModel.memories.isEmpty {
                    AddMemoryButton(smileViewModel: smileViewModel)
                } else {
                    ForEach(smileViewModel.memories) { memory in
                        MemoryButton(smileViewModel: smileViewModel, memory: memory)
                    }

                    AddMemoryButton(smileViewModel: smileViewModel)
                }
            }
        }
    }
}

struct AddMemoryButton: View {
    @ObservedObject var smileViewModel: SmileViewModel

    var body: some View {
        Button {
            smileViewModel.perform(action: .memoryAddButtonTapped)
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

struct MemoryButton: View {
    @ObservedObject var smileViewModel: SmileViewModel

    let memory: MemoryModel

    var body: some View {
        Button {
            smileViewModel.perform(action: .memoryTapped(memory))
        } label: {
            if let uiImage = UIImage(data: memory.imageData) {
                KFImage(source: .provider(RawImageDataProvider(data: memory.imageData, cacheKey: memory.dateCreated.description)))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .contentShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 150, height: 200)
                    .foregroundStyle(Color(uiColor: .systemGray6))
            }
        }
        .fullScreenCover(item: $smileViewModel.tappedMemory) { memory in
            MemoryImageFullScreenView(memory: memory)
        }
        .supportsLongPress {
            smileViewModel.perform(action: .memoryLongPressed(memory))
        }
    }
}

struct MemoryImageFullScreenView: View {
    let memory: MemoryModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            if let uiImage = UIImage(data: memory.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                    .modifier(SwipeToDismissModifier(onDismiss: {
                        dismiss()
                    }))
            }
        }
    }

    struct SwipeToDismissModifier: ViewModifier {
        @State private var offset: CGSize = .zero

        var onDismiss: () -> Void

        func body(content: Content) -> some View {
            content
                .offset(y: offset.height)
                .animation(.interactiveSpring(), value: offset)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.width < 50 {
                                offset = gesture.translation
                            }
                        }
                        .onEnded { _ in
                            if abs(offset.height) > 100 {
                                onDismiss()
                            } else {
                                offset = .zero
                            }
                        }
                )
        }
    }
}

struct UIImagePicker: UIViewControllerRepresentable {
    @ObservedObject var smileViewModel: SmileViewModel

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: UIImagePicker

        init(_ parent: UIImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true) {
                if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    withAnimation {
                        self.parent.smileViewModel.perform(action: .selectImage(uiImage))
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    typealias UIViewControllerType = UIImagePickerController

}

// MARK: - Contacts

struct ContactListView: View {
    @ObservedObject var smileViewModel: SmileViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if smileViewModel.savedContacts.isEmpty {
                    AddContactButton(smileViewModel: smileViewModel)
                } else {
                    ForEach(smileViewModel.savedContacts) { contact in
                        ContactButton(
                            smileViewModel: smileViewModel, contact: contact
                        )
                    }

                    AddContactButton(smileViewModel: smileViewModel)
                }
            }
        }
    }
}

struct AddContactButton: View {
    @ObservedObject var smileViewModel: SmileViewModel

    var body: some View {
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

struct ContactButton: View {
    @ObservedObject var smileViewModel: SmileViewModel

    let contact: ContactModel

    var body: some View {
        Link(destination: URL(string: "tel:\(contact.phoneNumber)")!) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 150, height: 200)
                    .foregroundStyle(Color(uiColor: .systemGray6))

                VStack {
                    if let uiImage = UIImage(data: contact.imageData) {
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
            smileViewModel.perform(action: .contactLongPressed(contact))
        }
    }
}

struct ContactListSheet: View {
    @ObservedObject var smileViewModel: SmileViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(smileViewModel.filteredContacts, id: \.id) { contact in
                Button {
                    withAnimation {
                        smileViewModel.perform(action: .contactListRowTapped(contact))
                    }

                    dismiss()
                } label: {
                    ContactRow(contact: contact)
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .searchable(text: $smileViewModel.contactSearchText,
                    placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
        .alert("Uttcha", isPresented: $smileViewModel.isShowingContactAuthorizationAlert) {
            Button("Cancel", role: .cancel) { }

            Button("Go to Settings") {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil)
            }
        } message: {
            Text("The app doesn't have contacts access. Please update your settings.")
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
            if let uiImage = UIImage(data: contact.imageData) {
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
                Text("\(contact.familyName)\(contact.givenName )").fontWeight(.semibold)

                Text("\(contact.phoneNumber)")
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
        imageData: UIImage(systemName: "person.circle.fill")!.pngData()!
    )

    return ContactRow(contact: contact)
}
