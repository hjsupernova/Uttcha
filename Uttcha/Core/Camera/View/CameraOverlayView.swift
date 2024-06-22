//
//  CameraOverlayView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import SwiftUI

struct CameraOverlayView: View {
    @ObservedObject var model: CameraViewModel

    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.black)

                    ProgressView("Keep Smile 😆", value: model.smileProgress, total: 100)
                        .foregroundStyle(.white)
                }

                Spacer()
                    .frame(height: geo.size.width * 4 / 3)

                ZStack {
                    Rectangle()
                        .fill(Color.black)

                    HStack(spacing: 20) {
                        Button {
                            model.perform(action: .dismissCamera)
                        } label: {
                            Text("취소")
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        if model.smileProgress == 100 {
                            Shutter()
                                .onTapGesture {
                                    model.perform(action: .takePhoto)
                                }
                        }

                        Spacer()

                        EmptyView()
                    }
                }
            }
        }
    }
}

#Preview {
    CameraOverlayView(model: CameraViewModel())
}
