//
//  HomeViewModel.swift
//  CalendarTest
//
//  Created by KHJ on 2024/04/27.
//

import Foundation

enum Sheet: String, Identifiable {
    case photoDetail, monthsAvailable

    var id: String { rawValue }
}

enum HomeViewModelAction {
    case cameraButtonTapped
    case showMonthsSheet
    case photoTapped
    case photoRemoveButtonTapped(Photo)
    case saveButtonTapped
    case userScroll(DateComponents, DateComponents)
    case monthRowTapped(Date)
    case appDidBecomeActive
}

final class HomeViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var isShowingCameraView: Bool = false
    @Published private(set) var photos: Set<Photo> = [] {
        didSet {
            calculateButtonAvailabilty()
        }
    }
    @Published var isCameraButtonDisabled: Bool = false
    @Published private(set) var fireworkTrigger = 0
    @Published private(set) var fireworkConfiguration: FireworkConfig = FireworkConfig()
    @Published var presentedSheet: Sheet?

    // MARK: - Private properties
    private var visualizedMonths: Set<DateComponents> = []

    // MARK: - Initializer
    init() {
        fetchPhotos(in: yearMonthComponents(from: Date()))
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
            fetchPhotos(in: yearMonthComponents(from: Date()))
            NotificationManager.cancelNotificationFor(Date.now)
            triggerFireworks()
        case .userScroll(let lowerBound, let upperBound):
            fetchPhotosOnScrollIfNeeded(lowerBound: yearMonthComponents(from: lowerBound),
                                         upperBound: yearMonthComponents(from: upperBound))
        case .monthRowTapped(let selectedMonth):
            fetchPhotos(in: yearMonthComponents(from: selectedMonth))
        case .appDidBecomeActive:
            calculateButtonAvailabilty()
        }
    }

    // MARK: - Action Handlers
    private func showCameraView() {
        isShowingCameraView = true
    }

    private func showMonthsSheet() {
        presentedSheet = .monthsAvailable
    }

    private func showDetailView() {
        presentedSheet = .photoDetail
    }

    private func removePhoto(_ photo: Photo) {
        CoreDataStack.shared.removePhoto(photo)
        photos.remove(photo)
    }

    private func fetchPhotos(in month: DateComponents) {
        let newPhotos = CoreDataStack.shared.fetchPhotos(for: month)
        photos.formUnion(newPhotos)
        visualizedMonths.insert(month)
    }

    private func fetchPhotosOnScrollIfNeeded(lowerBound: DateComponents, upperBound: DateComponents) {

        if !visualizedMonths.contains(lowerBound) {
            let newPhotos = CoreDataStack.shared.fetchPhotos(for: lowerBound)
            photos.formUnion(newPhotos)
            visualizedMonths.insert(lowerBound)
        } else if !visualizedMonths.contains(upperBound) {
            let newPhotos = CoreDataStack.shared.fetchPhotos(for: upperBound)
            photos.formUnion(newPhotos)
            visualizedMonths.insert(upperBound)
        }
    }
    
    private func triggerFireworks() {
        fireworkTrigger += 1
    }

    private func calculateButtonAvailabilty() {
        if photos.isEmpty {
            isCameraButtonDisabled = false
        } else {
            for photo in photos {
                if let date = photo.dateCreated {
                    isCameraButtonDisabled = Calendar.current.isDateInToday(date)
                    return
                }

                isCameraButtonDisabled = false
            }
        }
    }
}

// MARK: - Private instance methods

extension HomeViewModel {
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
