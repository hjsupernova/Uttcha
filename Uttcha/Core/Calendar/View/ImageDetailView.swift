//
//  ImageDetailView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import SwiftUI

struct ImageDetailView: View {
    let selectedImage: Photo?

    @State private var text: String = ""
    @Environment(\.dismiss) var dismiss
    @FocusState var inFocus: Int?

    var body: some View {
        NavigationStack {
            Group {
                if let image = selectedImage, let uiImage = UIImage(data: image.blob!) {
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
                        text = image.memo ?? ""
                    }
                    .onChange(of: text) { _, _ in
                        image.memo = text
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            if let selectedImage = selectedImage {
                                CoreDataStack.shared.removePhoto(selectedImage)

                                CoreDataStack.shared.getImageList()
                            }

                            dismiss()
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
                    Text(selectedImage?.date?.string(withFormat: "M월 d일 HH:mm") ?? "")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let context = CoreDataStack.shared.persistentContainer.viewContext
    let samplePhoto = Photo(context: context)

    // Set up sample data
    samplePhoto.date = Date()
    samplePhoto.memo = ""

    // Create a sample image and convert it to Data
    if let sampleImage = UIImage(systemName: "photo"),
       let imageData = sampleImage.pngData() {
        samplePhoto.blob = imageData
    }

    return ImageDetailView(selectedImage: samplePhoto)
        .environment(\.managedObjectContext, context)
}
