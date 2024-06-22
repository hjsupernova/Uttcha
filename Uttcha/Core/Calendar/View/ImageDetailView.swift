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

                            TextEditor(text: $text).id(0)
                                .focused($inFocus, equals: 0)
                                .frame(height: 300)
                                .background(.yellow)
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
                    Button {
                        if let image = selectedImage {
                            image.memo = text
                            CoreDataStack.shared.save()
                        }
                        dismiss()
                    } label: {
                        Text("저장")
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
