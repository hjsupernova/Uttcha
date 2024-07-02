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
    case faceDetected(Int)
    case smileFaceDetected(FaceSmileModel)

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
    case faceDetected
    case noFaceDetected
    case faceDetectionErrored
}

enum FaceObservation<T> {
    case faceFound(T)
    case faceNotFound
    case erorred(Error)
}

struct FaceSmileModel {
    let hasSmile: Bool
}

final class CameraViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var neededFaceCount: Int = 1
    @Published private(set) var detectedFaceCount: Int = 0
    @Published private(set) var hasDetectedEnoughFaces: Bool = false
    @Published private(set) var smileProgress = 0.0
    @Published var isShowingCameraView = false
    @Published private(set) var hasDetectedSmileFaces: Bool
    @Published private(set) var hasSmile: Bool
    @Published var facePhoto: UIImage?
    @Published private(set) var smileInformation: String = "웃어보세요! 😍"
    @Published private(set) var faceDetectedState: FaceDetectedState
    @Published private(set) var faceSmileState: FaceObservation<FaceSmileModel> {
        didSet {
            processUpdatedSmile()
        }
    }

    // MARK: - Pirvate Properties
    private var timer: AnyCancellable?
    private var isTimerRunning: Bool = false

    // MARK: - Public Properties
    let shutterReleased = PassthroughSubject<Void, Never>()

    // MARK: - Initializaiton
    init() {
        faceDetectedState = .noFaceDetected
        faceSmileState = .faceNotFound
        hasDetectedSmileFaces = false
        hasDetectedEnoughFaces = false
        hasSmile = false
    }

    // MARK: - Actions
    func perform(action: CameraViewModelAction) {
        switch action {
        case .noFaceDetected:
            handleNoFaceDetected()
        case .faceDetected(let faceCount):
            handleFaceDetected(faceCount)
        case .smileFaceDetected(let faceSmileObservation):
            handleSmileFaceDetected(faceSmileObservation)

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
            faceSmileState = .faceNotFound
        }
    }

    private func handleFaceDetected(_ faceCount: Int) {
        DispatchQueue.main.async { [self] in
            faceDetectedState = .faceDetected
            detectedFaceCount = faceCount
            updateFaceDetectionState()
        }
    }

    private func handleSmileFaceDetected(_ faceSmileModel: FaceSmileModel) {
        DispatchQueue.main.async { [self] in
            faceDetectedState = .faceDetected
            faceSmileState = .faceFound(faceSmileModel)
        }
    }

    private func incrementNeededFaceCount() {
        neededFaceCount += 1
        updateFaceDetectionState()
    }

    private func decrementNeededFaceCount() {
        neededFaceCount = max(0, neededFaceCount - 1)
        updateFaceDetectionState()
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
    private func updateFaceDetectionState() {
        hasDetectedEnoughFaces = neededFaceCount == detectedFaceCount
        updateSmileInformation()
        updateSmileFaceDetectionState()
    }

    private func updateSmileFaceDetectionState() {
        hasDetectedSmileFaces = hasDetectedEnoughFaces && hasSmile
    }

    private func updateSmileInformation() {
        if hasDetectedEnoughFaces {
            smileInformation = "웃어보세요! 😍"
        } else {
            smileInformation = "\(neededFaceCount - detectedFaceCount) 명이 부족해요! 😭"
        }
    }

    private func processUpdatedSmile() {
        switch faceSmileState {
        case .faceNotFound, .erorred:
            hasSmile = false
            stopSmileTimer()
            resetSmileProgress()
        case .faceFound(let faceSmileModel):
            hasSmile = faceSmileModel.hasSmile
            if hasSmile {
                startSmileTimer()
            } else {
                stopSmileTimer()
                resetSmileProgress()
            }
        }
        updateSmileFaceDetectionState()
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
