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
    @Published var photos: [Photo] = [] {
        didSet {
             calculateButtonAvailabilty()
        }
    }
    @Published var isCameraButtonDisabled: Bool = false {
        didSet {
            print("isCameraButtonDisabled: \(isCameraButtonDisabled)")
        }
    }

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

// MARK: - Private instance methods

extension HomeViewModel {
    func calculateButtonAvailabilty() {
        print("Calcualte start")
        print("Photo count: \(photos.count)")
        if photos.isEmpty {
            isCameraButtonDisabled = false
        } else {
            for photo in photos {
                if let date = photo.date {
                    isCameraButtonDisabled = Calendar.current.isDateInToday(date)
                    return
                }

                isCameraButtonDisabled = false
            }
        }
    }
}
