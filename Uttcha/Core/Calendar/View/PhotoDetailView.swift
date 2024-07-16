//
//  PhotoDetailView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import SwiftUI

struct PhotoDetailView: View {
    @ObservedObject var homeViewModel: HomeViewModel

    @Binding var selectedPhoto: Photo?
    @Environment(\.dismiss) var dismiss
    @FocusState var inFocus: Int?
    @State private var text: String = ""

    var body: some View {
        NavigationStack {
            Group {
                if let photo = selectedPhoto,
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
                                    .focused($inFocus, equals: 0)
                                    .frame(height: 300)
                                    .background(.yellow)

                                if text.isEmpty {
                                    Text("오늘 하루를 기록해보세요.")
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
                    .onChange(of: text) { _, _ in
                        photo.memo = text
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            dismiss()

                            if let selectedPhoto = selectedPhoto {
                                homeViewModel.perform(action: .photoRemoveButtonTapped(selectedPhoto))
                            }

                        } label: {
                            HStack {
                                Text("삭제")
                                Spacer()
                                Image(systemName: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(selectedPhoto?.dateCreated?.string(withFormat: "M월 d일 HH:mm") ?? "")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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

    return PhotoDetailView(homeViewModel: HomeViewModel(), selectedPhoto: $samplePhoto)
        .environment(\.managedObjectContext, context)
}
