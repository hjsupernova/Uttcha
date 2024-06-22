//
//  CameraViewController.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/06.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI

class CameraViewController: UIViewController {
    var faceDetector: FaceDetector?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let session = AVCaptureSession()
    private let stillImageOutput = AVCapturePhotoOutput()

    let videoOutputQueue = DispatchSerialQueue(
        label: "VideoOutputQueue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem
    )

    override func viewDidLoad() {
        configureCaptureSession()
        setupSaveToCameraRoll()
        session.startRunning()
    }

    private func configureCaptureSession() {
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            // TODO: Error Handling
            return
        }

        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)

            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            }
        } catch {
            // TODO: Error
            return
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(faceDetector, queue: videoOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspect
        previewLayer?.frame = view.bounds

        if let previewLayer = previewLayer {
            view.layer.insertSublayer(previewLayer, at: 0)
        }
    }

    private func setupSaveToCameraRoll() {
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
    }
}
