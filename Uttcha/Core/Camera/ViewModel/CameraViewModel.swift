//
//  CameraViewModel.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/08.
//

import Combine
import UIKit

enum CameraViewModelAction {

    // Face detection actions 
    case noFaceDetected
    case faceDetected(Int, Bool)

    // faceCount
    case incrementNeededFaceCount
    case decrementNeededFaceCount

    // Camera
    case takePhoto
    case updatePreviewPhoto(UIImage)
    case savePhoto(UIImage)
    case showCamera
    case dismissCamera
}

enum FaceDetectedState {
    case faceDetected(Bool)
    case noFaceDetected
    case faceDetectionErrored
}

final class CameraViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var neededFaceCount: Int = 1
    @Published private(set) var detectedFaceCount: Int = 0
    @Published private(set) var hasDetectedEnoughFaces: Bool = false
    @Published private(set) var smileProgress = 0.0
    @Published var isShowingCameraView = false
    @Published private(set) var hasDetectedEnoughSmileFaces: Bool
    @Published private(set) var hasSmile: Bool
    @Published var facePhoto: UIImage?
    @Published private(set) var cameraInstructionText: String = "웃어보세요! 😍"
    @Published private(set) var faceDetectedState: FaceDetectedState


    // MARK: - Pirvate Properties
    private var timer: AnyCancellable?
    private var isTimerRunning: Bool = false

    // MARK: - Public Properties
    let shutterReleased = PassthroughSubject<Void, Never>()

    // MARK: - Initializaiton
    init() {
        faceDetectedState = .noFaceDetected
        hasDetectedEnoughSmileFaces = false
        hasDetectedEnoughFaces = false
        hasSmile = false
    }

    // MARK: - Actions
    func perform(action: CameraViewModelAction) {
        switch action {
        case .noFaceDetected:
            handleNoFaceDetected()
        case .faceDetected(let faceCount, let allSmiling):
            handleFaceDetected(faceCount, allSmiling)

        case .incrementNeededFaceCount:
            incrementNeededFaceCount()
        case .decrementNeededFaceCount:
            decrementNeededFaceCount()

        case .takePhoto:
            takePhoto()
        case .savePhoto(let image):
            savePhotoPersistentStore(image)
        case .updatePreviewPhoto(let image):
            updatePreviewPhoto(image)
        case .showCamera:
            showCamera()
        case .dismissCamera:
            dismissCamera()
        }
    }

    // MARK: - Action Handlers

    private func handleNoFaceDetected() {
        DispatchQueue.main.async { [self] in
            faceDetectedState = .noFaceDetected
            processFaceDetectionResult()
        }
    }

    private func handleFaceDetected(_ faceCount: Int, _ allSmiling: Bool) {
        DispatchQueue.main.async { [self] in
            faceDetectedState = .faceDetected(allSmiling)
            detectedFaceCount = faceCount
            processFaceDetectionResult()
            updateCameraInstructionText()
        }
    }

    private func incrementNeededFaceCount() {
        neededFaceCount += 1
        processFaceDetectionResult()
    }

    private func decrementNeededFaceCount() {
        neededFaceCount = max(1, neededFaceCount - 1)
        processFaceDetectionResult()
    }

    private func takePhoto() {
        shutterReleased.send()
    }

    private func savePhotoPersistentStore(_ photo: UIImage) {
        CoreDataStack.shared.saveImage(photo)

        facePhoto = nil
        dismissCamera()
    }

    private func updatePreviewPhoto(_ photo: UIImage) {
        DispatchQueue.main.async { [self] in
            facePhoto = photo
        }
    }

    private func showCamera() {
        isShowingCameraView = true
    }

    private func dismissCamera() {
        isShowingCameraView = false
    }
}

// MARK: - Private instance methods

extension CameraViewModel {
    private func processFaceDetectionResult() {
        switch faceDetectedState {
        case .noFaceDetected, .faceDetectionErrored:
            stopSmileTimer()
            resetSmileProgress()
        case .faceDetected(let allSmiling):
            hasDetectedEnoughFaces = neededFaceCount == detectedFaceCount
            if hasDetectedEnoughFaces && allSmiling {
                startSmileTimer()
            } else {
                stopSmileTimer()
                resetSmileProgress()
            }
        }
    }

    private func updateCameraInstructionText() {
        if hasDetectedEnoughFaces {
            cameraInstructionText = "웃어보세요! 😍"
        } else {
            cameraInstructionText = "\(neededFaceCount - detectedFaceCount) 명이 부족해요! 😭"
        }
    }

    private func startSmileTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.smileProgress < 100 {
                    self.smileProgress += 5
                }
            }
    }

    private func stopSmileTimer() {
        timer?.cancel()
        timer = nil
        isTimerRunning = false
    }

    private func resetSmileProgress() {
        smileProgress = 0.0
    }
}
