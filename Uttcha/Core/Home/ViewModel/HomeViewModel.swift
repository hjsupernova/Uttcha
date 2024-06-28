//
//  HomeViewModel.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/27.
//

import Foundation

enum HomeViewModelAction {
    case cameraButtonTapped
    case showMonthsSheet
    case photoTapped
    case photoRemoveButtonTapped(Photo)
    case saveButtonTapped
}

final class HomeViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var isShowingCameraView: Bool = false
    @Published var isShowingMonthsSheet = false
    @Published var isShowingDetailView = false
    @Published var photos: [Photo] = []

    init() {
        getImageList()
    }

    // MARK: - Actions
    func perform(action: HomeViewModelAction) {
        switch action {
        case .cameraButtonTapped:
            showCameraView()
        case .showMonthsSheet:
            showMonthsSheet()
        case .photoTapped:
            showDetailView()
        case .photoRemoveButtonTapped(let photo):
            removePhoto(photo)
        case .saveButtonTapped:
            getImageList()
        }
    }

    // MARK: - Action Handlers
    private func showCameraView() {
        isShowingCameraView = true
    }

    private func showMonthsSheet() {
        isShowingMonthsSheet = true
    }

    private func showDetailView() {
        isShowingDetailView = true
    }

    private func removePhoto(_ photo: Photo) {
        CoreDataStack.shared.removePhoto(photo)
        getImageList()
    }

    private func getImageList() {
        photos = CoreDataStack.shared.getImageList()
    }
}
