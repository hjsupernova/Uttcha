//
//  CameraView.swift
//  CalendarTest
//
//  Created by KHJ on 2024/05/06.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    private(set) var model: CameraViewModel

    func makeUIViewController(context: Context) -> CameraViewController {
        let faceDetector = FaceDetector()
        faceDetector.model = model

        let viewController = CameraViewController()
        viewController.faceDetector = faceDetector

        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) { }
}

#Preview {
    CameraView(model: CameraViewModel())
}
