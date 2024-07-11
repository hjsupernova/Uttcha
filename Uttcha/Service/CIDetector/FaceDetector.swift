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

            savePhoto(from: imageBuffer)
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
    private func savePhoto(from pixelBuffer: CVPixelBuffer) {
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
                let photo = UIImage(cgImage: cgImage, scale: 1, orientation: .upMirrored)

                DispatchQueue.main.async {
                    model.perform(action: .updatePreviewPhoto(photo))
                }
            }
        }
    }

    private func processFaceFeatures(from sourceImage: CIImage) {
        guard let model = model else { return }
        guard let faceFeatures = faceDector?.features(in: sourceImage, options: options) as? [CIFaceFeature] else {
            model.perform(action: .noFaceDetected)
            return
        }

        let faceCount = faceFeatures.count
        let allSmiling = faceFeatures.allSatisfy { $0.hasSmile }
        model.perform(action: .faceDetected(faceCount, allSmiling))
    }
}
