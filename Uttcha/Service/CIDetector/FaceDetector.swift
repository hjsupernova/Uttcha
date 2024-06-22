//
//  FaceDetector.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/06.
//

import AVFoundation
import Combine
import CoreImage.CIFilterBuiltins
import UIKit

class FaceDetector: NSObject {
    public weak var model: CameraViewModel? {
        didSet {
            model?.shutterReleased.sink { completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    print("Received error: \(error)")
                }
            } receiveValue: { _ in
                self.isCapturingPhoto = true
            }
            .store(in: &subscriptions)
        }
    }

    var options: [String : AnyObject]?
    var isCapturingPhoto = false
    var subscriptions = Set<AnyCancellable>()

    let imageProcessingQueue = DispatchQueue(
        label: "ImageProcessingQueue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem
    )

    var faceDector = CIDetector(
        ofType: CIDetectorTypeFace,
        context: nil,
        options: [CIDetectorAccuracy : CIDetectorAccuracyHigh as AnyObject]
    )
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods

extension FaceDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let model = model, let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        if isCapturingPhoto {
            isCapturingPhoto = false

            savePassportPhoto(from: imageBuffer)
        }

        // PixelBuffer을 CIImage로 변경하는 작업
        var sourceImage = CIImage()
        let opaqueBuffer = Unmanaged<CVImageBuffer>.passUnretained(imageBuffer).toOpaque()
        let pixelBuffer = Unmanaged<CVPixelBuffer>.fromOpaque(opaqueBuffer).takeUnretainedValue()
        sourceImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)

        options = [
            CIDetectorSmile: true as AnyObject,
            CIDetectorImageOrientation: 6 as AnyObject
        ]

        processFaceFeatures(from: sourceImage)
    }
}

// MARK: - Private methods

extension FaceDetector {
    private func savePassportPhoto(from pixelBuffer: CVPixelBuffer) {
        guard let model = model else { return }
        imageProcessingQueue.async { [self] in
            let originalImage = CIImage(cvPixelBuffer: pixelBuffer)

            var outputImage = originalImage

            let coreImageWidth = outputImage.extent.width
            let coreImageHeight = outputImage.extent.height

            let desiredImageHeight = coreImageWidth * 4 / 3

            // Calculate frame of photo
            let yOrigin = (coreImageHeight - desiredImageHeight) / 2
            let photoRect = CGRect(
                x: 0,
                y: yOrigin,
                width: coreImageWidth,
                height: desiredImageHeight
            )

            let context = CIContext()
            if let cgImage = context.createCGImage(outputImage, from: photoRect) {
                let passportPhoto = UIImage(cgImage: cgImage, scale: 1, orientation: .upMirrored)

                DispatchQueue.main.async {
                    model.perform(action: .updatePreviewPhoto(passportPhoto))
                }
            }
        }
    }

    private func processFaceFeatures(from sourceImage: CIImage) {
        guard let model = model else { return }
        if let faceFeatures = faceDector?.features(in: sourceImage, options: options) as? [CIFaceFeature] {
            let faceCount = faceFeatures.count
            model.perform(action: .faceObservationDetected(faceCount))

            if faceCount == model.neededFaceCount {
                if faceFeatures.map({ $0.hasSmile }).contains(false) {
                    model.perform(action: .faceSmileObservationDetected(FaceSmileModel(hasSmile: false)))
                } else {
                    model.perform(action: .faceSmileObservationDetected(FaceSmileModel(hasSmile: true)))
                }
            } else {
                model.perform(action: .noFaceDetected)
            }
        } else {
            model.perform(action: .noFaceDetected)
        }
    }
}
