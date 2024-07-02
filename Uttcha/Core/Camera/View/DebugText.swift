//
//  DebugText.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/12.
//

import SwiftUI

struct DebugText: View {
    @ObservedObject var model: CameraViewModel

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 5) {
//                DebugSection(observation: model.faceSmileState) { faceSmileModel in
//                    Text("Has Smile: \(faceSmileModel.hasSmile.description)")
//                    Text("인식된 얼굴: \(model.detectedFaceCount)개")
//                    Text("필요한 얼굴:  \(model.neededFaceCount)개")
//                }
//                .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//struct DebugSection<Model, Content: View>: View {
//    let observation: FaceObservation<Model>
//    let content: (Model) -> Content
//
//    public init(
//        observation: FaceObservation<Model>,
//        @ViewBuilder content: @escaping (Model) -> Content
//    ) {
//        self.observation = observation
//        self.content = content
//    }
//
//    var body: some View {
//        switch observation {
//        case .faceFound(let model):
//            AnyView(content(model))
//        case .faceNotFound:
//            AnyView(Spacer())
//        case .erorred(let error):
//            AnyView(Text("ERROR: \(error.localizedDescription)"))
//        }
//    }
//}

#Preview {
    DebugText(model: CameraViewModel())
}
