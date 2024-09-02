//
//  CameraViewModel.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/08.
//

import Combine
import SwiftUI
import UIKit

enum CameraViewModelAction {

    // Face detection actions 
    case noFaceDetected
    case faceDetected(Int, Bool)

    // Camera
    case takePhoto
    case updatePreviewPhoto(UIImage)
    case savePhoto(UIImage)
    case showCamera
    case dismissCamera
    case onOverlayViewAppeared
}

enum FaceDetectedState {
    case faceDetected(Int, Bool)
    case noFaceDetected
    case faceDetectionErrored
}

final class CameraViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var faceDetectedState: FaceDetectedState = .noFaceDetected
    @Published private(set) var smileProgress = 0.0
    @Published var neededFaceCount: Int = 1
    @Published var isShowingCameraView = false
    @Published var isShowingPhotoPreviewView = false

    // MARK: - Pirvate Properties
    private var hasDetectedEnoughFaces: Bool = false
    private(set) var cameraInstructionText: String = "웃어봐요 😊"
    private(set) var facePhoto: UIImage?
    private var timer: AnyCancellable?
    private var isTimerRunning: Bool = false
    private var hasTriggeredStartSmileHaptic = false
    private var hasTriggeredCompleteSmileHaptic = false
    private var debounceWorkItem: DispatchWorkItem?

    // MARK: - Public Properties
    let shutterReleased = PassthroughSubject<Void, Never>()

    // MARK: - Actions
    func perform(action: CameraViewModelAction) {
        switch action {
        case .noFaceDetected:
            handleNoFaceDetected()
        case .faceDetected(let faceCount, let allSmiling):
            handleFaceDetected(faceCount, allSmiling)

        case .takePhoto:
            takePhoto()
        case .savePhoto(let photo):
            savePhotoPersistentStore(photo)
        case .updatePreviewPhoto(let photo):
            updatePreviewPhoto(photo)

        case .showCamera:
            showCamera()
        case .dismissCamera:
            dismissCamera()
        case .onOverlayViewAppeared:
            resetSmileProgress()
        }
    }

    // MARK: - Action Handlers

    private func handleNoFaceDetected() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            faceDetectedState = .noFaceDetected
            processFaceState(faceState: faceDetectedState)
        }
    }

    private func handleFaceDetected(_ faceCount: Int, _ allSmiling: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            faceDetectedState = .faceDetected(faceCount, allSmiling)
            processFaceState(faceState: faceDetectedState)
        }
    }

    private func takePhoto() {
        shutterReleased.send()
    }

    private func savePhotoPersistentStore(_ photo: UIImage) {
        CoreDataStack.shared.savePhoto(photo)

        facePhoto = nil
        isShowingPhotoPreviewView = false
        dismissCamera()
    }

    private func updatePreviewPhoto(_ photo: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            facePhoto = photo
            isShowingPhotoPreviewView = true
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
    private func processFaceState(faceState: FaceDetectedState) {
        switch faceState {
        case .noFaceDetected, .faceDetectionErrored:
            stopSmileTimer()
            resetSmileProgress()
        case .faceDetected(let faceCount, let allSmiling):
            updateInstructionText(faceCount: faceCount)

            if hasDetectedEnoughFaces && allSmiling {
                startSmileTimer()
            } else {
                stopSmileTimer()
                resetSmileProgress()
            }
        }
    }

    private func updateInstructionText(faceCount: Int) {
        hasDetectedEnoughFaces = faceCount >= neededFaceCount

        cameraInstructionText = hasDetectedEnoughFaces ? "웃어봐요 😊" : "\(neededFaceCount - faceCount) 명이 부족해요! 🥲"
    }

    private func startSmileTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true

        debounceWorkItem?.cancel()
        debounceWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            HapticManager.impact(style: .medium)
            self.hasTriggeredStartSmileHaptic = true
        }
        if let workItem = debounceWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
        }

        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.smileProgress < 100 {
                    withAnimation {
                        self.smileProgress += 10
                    }
                } else if self.smileProgress >= 100 {
                    if !hasTriggeredCompleteSmileHaptic {
                        HapticManager.impact(style: .medium)
                        hasTriggeredCompleteSmileHaptic = true
                    }
                }
            }
    }

    private func stopSmileTimer() {
        timer?.cancel()
        timer = nil
        isTimerRunning = false

        // reset flags
        hasTriggeredStartSmileHaptic = false
        hasTriggeredCompleteSmileHaptic = false
        debounceWorkItem?.cancel()
        debounceWorkItem = nil
    }

    private func resetSmileProgress() {
        smileProgress = 0.0
    }
}
