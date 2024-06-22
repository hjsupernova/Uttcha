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
    case faceObservationDetected(Int)
    case faceSmileObservationDetected(FaceSmileModel)

    // Other
    case takePhoto
    case updatePreviewPhoto(UIImage)
    case savePhoto(UIImage)
    case showCamera
    case dismissCamera

    // faceCount
    case faceCountIncrement
    case faceCountDecrement
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
    // MARK: - Publihsers
    @Published var neededFaceCount: Int = 1 {
        didSet {
            calculateDetectedFaceEnoughness()
        }
    }
    @Published private(set) var detectedFaceCount: Int = 0 {
        didSet {
            calculateDetectedFaceEnoughness()
        }
    }

    @Published private(set) var hasDetectedEnoughFaces: Bool {
        didSet {
            calculateDetectedEnoughSmileFaces()
        }
    }

    @Published private(set) var smileProgress = 0.0
    @Published var isShowingCameraView = false
    // MARK: - Publihser of derived state
    @Published private(set) var hasDetectedSmileFaces: Bool
    @Published private(set) var hasSmile: Bool

    @Published var facePhoto: UIImage?
    // MARK: - Publishers of Vision Data directly
    @Published private(set) var faceDetectedState: FaceDetectedState
    @Published private(set) var faceSmileState: FaceObservation<FaceSmileModel> {
        didSet {
            processUpdatedSmile()
        }
    }

    // MARK: - Public properties
    let shutterReleased = PassthroughSubject<Void, Never>()
    private var timer: AnyCancellable?
    private var isTimerRunning: Bool = false

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
            publishNoFaceObserved()
        case .faceObservationDetected(let faceCount):
            publishFaceObservation(faceCount)
        case .faceSmileObservationDetected(let faceSmileObservation):
            publishFaceSmileObservation(faceSmileObservation)
        case .takePhoto:
            takePhoto()
        case .savePhoto(let image):
            savePhotoPersistentStore(image)
        case .faceCountIncrement:
            neededFaceCountIncrement()
        case .faceCountDecrement:
            neededFaceCountDecrement()
        case .updatePreviewPhoto(let image):
            updatePreviewPhoto(image)
        case .showCamera:
            showCamera()
        case .dismissCamera:
            dismissCamera()
        }
    }

    // MARK: - Action Handlers

    private func publishNoFaceObserved() {
        DispatchQueue.main.async { [self] in
            faceDetectedState = .noFaceDetected
            faceSmileState = .faceNotFound
        }
    }

    private func publishFaceObservation(_ faceCount: Int) {
        DispatchQueue.main.async { [self] in
            faceDetectedState = .faceDetected
            detectedFaceCount = faceCount
        }
    }

    private func publishFaceSmileObservation(_ faceSmileModel: FaceSmileModel) {
        DispatchQueue.main.async { [self] in
            faceDetectedState = .faceDetected
            faceSmileState = .faceFound(faceSmileModel)
        }
    }

    private func takePhoto() {
        shutterReleased.send()
    }

    private func savePhotoPersistentStore(_ photo: UIImage) {
        CoreDataStack.shared.saveImage(photo)
        CoreDataStack.shared.getImageList()

        facePhoto = nil
        dismissCamera()
    }

    private func neededFaceCountIncrement() {
        neededFaceCount += 1
    }

    private func neededFaceCountDecrement() {
        neededFaceCount -= 1
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
    func processUpdatedSmile() {
        switch faceSmileState {
        case .faceNotFound:
            hasSmile = false

        case .erorred(let error ):
            print(error.localizedDescription)
            hasSmile = false
        case .faceFound(let faceSmileModel):
            hasSmile = faceSmileModel.hasSmile
            if hasSmile {
                startSmileTimer()
            } else {
                stopSmileTimer()
                resetSmileProgress()
            }
        }
    }

    func calculateDetectedFaceEnoughness() {
        hasDetectedEnoughFaces =
            neededFaceCount == detectedFaceCount
    }

    func calculateDetectedEnoughSmileFaces() {
        hasDetectedSmileFaces =
            hasDetectedEnoughFaces && hasSmile
    }
}

extension CameraViewModel {

    private func startSmileTimer() {
        if isTimerRunning == false {

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
