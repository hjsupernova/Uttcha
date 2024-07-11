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
    case userScroll(DateComponents, DateComponents)
    case monthRowTapped(Date)
}

final class HomeViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var isShowingCameraView: Bool = false
    @Published var isShowingMonthsSheet = false
    @Published var isShowingDetailView = false
    @Published var photos: Set<Photo> = [] {
        didSet {
            calculateButtonAvailabilty()
        }
    }
    @Published var isCameraButtonDisabled: Bool = false
    @Published var fireworkTrigger = 0
    @Published var fireworkConfiguration: FireworkConfig = FireworkConfig()

    private var visualizedMonths: Set<DateComponents> = []

    init() {
        getPhotos(in: yearMonthComponents(from: Date()))
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
            getPhotos(in: yearMonthComponents(from: Date()))
            NotificationManager.cancelNotificationFor(Date.now)
            triggerFireworks()
        case .userScroll(let lowerBound, let upperBound):
            getPhotosOnScrollIfNeeded(lowerBound: yearMonthComponents(from: lowerBound),
                                         upperBound: yearMonthComponents(from: upperBound))
        case .monthRowTapped(let selectedMonth):
            getPhotos(in: yearMonthComponents(from: selectedMonth))
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
        photos.remove(photo)
    }

    private func getPhotos(in month: DateComponents) {
        let newPhotos = CoreDataStack.shared.getPhotos(for: month)
        photos.formUnion(newPhotos)
        visualizedMonths.insert(month)
    }

    private func getPhotosOnScrollIfNeeded(lowerBound: DateComponents, upperBound: DateComponents) {

        if !visualizedMonths.contains(lowerBound) {
            let newPhotos = CoreDataStack.shared.getPhotos(for: lowerBound)
            photos.formUnion(newPhotos)
            visualizedMonths.insert(lowerBound)
        } else if !visualizedMonths.contains(upperBound) {
            let newPhotos = CoreDataStack.shared.getPhotos(for: upperBound)
            photos.formUnion(newPhotos)
            visualizedMonths.insert(upperBound)
        }
    }
    
    private func triggerFireworks() {
        fireworkTrigger += 1
    }

}

// MARK: - Private instance methods

extension HomeViewModel {
    private func calculateButtonAvailabilty() {
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

    private func yearMonthComponents(from components: DateComponents) -> DateComponents {
        var yearMonth = DateComponents()
        yearMonth.year = components.year
        yearMonth.month = components.month
        return yearMonth
    }

    private func yearMonthComponents(from date: Date) -> DateComponents {
        let calendar = Calendar.current
        var yearMonth = calendar.dateComponents([.year, .month], from: date)
        yearMonth.era = nil
        yearMonth.isLeapMonth = nil
        return yearMonth
    }
}
