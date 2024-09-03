//
//  PhotoDetailView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import SwiftUI

struct PhotoDetailView: View {
    @ObservedObject var homeViewModel: HomeViewModel

    @Environment(\.dismiss) var dismiss
    @FocusState var inFocus: Int?
    @State private var text: String = ""

    var body: some View {
        NavigationStack {
            Group {
                if let photo = homeViewModel.selectedPhoto,
                   let imageData = photo.imageData,
                   let uiImage = UIImage(data: imageData) {
                    ScrollViewReader { sp in
                        ScrollView {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .padding(4)

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $text).id(0)
                                    .frame(height: 300)
                                    .background(.yellow)
                                    .focused($inFocus, equals: 0)

                                if text.isEmpty {
                                    Text("Record your day here.")
                                        .foregroundColor(Color(UIColor.placeholderText))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                        .onChange(of: inFocus) { id in
                            withAnimation {
                                sp.scrollTo(id)
                            }
                        }
                    }
                    .onAppear {
                        text = photo.memo ?? ""
                    }
                    .onChange(of: text) { _ in
                        photo.memo = text
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            dismiss()

                            if let selectedPhoto = homeViewModel.selectedPhoto {
                                homeViewModel.perform(action: .photoRemoveButtonTapped(selectedPhoto))
                            }

                        } label: {
                            HStack {
                                Text("Delete")
                                Spacer()
                                Image(systemName: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(homeViewModel.selectedPhoto?.dateCreated?.toStringFromTemplate("MMMd HH:mm") ?? "")
                }
            }
        }
    }
}

#Preview {
    let context = CoreDataStack.shared.persistentContainer.viewContext
    @State var samplePhoto: Photo? = {
          let photo = Photo(context: context)
          photo.dateCreated = Date()
          photo.memo = ""

          // Create a sample image and convert it to Data
          if let samplePhoto = UIImage(systemName: "photo"),
             let photoData = samplePhoto.pngData() {
              photo.imageData = photoData
          }

          return photo
      }()

    return PhotoDetailView(homeViewModel: HomeViewModel())
        .environment(\.managedObjectContext, context)
}
