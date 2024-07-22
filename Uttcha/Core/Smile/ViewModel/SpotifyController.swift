//
//  SpotifyController.swift
//  Uttcha
//
//  Created by KHJ on 7/20/24.
//

import Combine
import Foundation

import SpotifyiOS

enum SpotifyControllerAction {
    case addTrackButtonTapped
}

class SpotifyController: NSObject, ObservableObject {
    // MARK: - Publishers
    @Published private(set) var tracks: [TrackModel] = []

    // MARK: - Private properties
    static private let kAccessTokenKey = "access-token-key"
    private let spotifyClientID = Bundle.main.spotifyClientID
    private let spotifyRedirectURL = URL(string:"spotify-ios-quick-start://spotify-login-callback")!
    private var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.setValue(accessToken, forKey: SpotifyController.kAccessTokenKey)
        }
    }
    private var isAddButtonTapped = false

    private var connectCancellable: AnyCancellable?
    private var disconnectCancellable: AnyCancellable?

    private lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID,
        redirectURL: spotifyRedirectURL
    )

    private lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    // MARK: - Initializer
    override init() {
        super.init()

        connectCancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.connect()
            }

        disconnectCancellable = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.disconnect()
            }
    }

    // MARK: - Actions
    func perform(action: SpotifyControllerAction) {
        switch action {
        case .addTrackButtonTapped:
            ensureSpotifyConnection()
        }
    }

    // MARK: - Action Handlers

    private func ensureSpotifyConnection() {
        if !appRemote.isConnected {
            authorize()
        } else {
            open()
        }

        isAddButtonTapped = true
    }

    func setAccessToken(from url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)

        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print(errorDescription)
        }
    }

    func connect() {
        if let _ = self.appRemote.connectionParameters.accessToken {
            appRemote.connect()
        } else {
            print("No access Token")
        }
    }

    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
}

// MARK: - Private instance methods

extension SpotifyController {
    private func authorize() {
        self.appRemote.authorizeAndPlayURI("")
    }

    private func open() {
        if let url = URL(string: "spotify://"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Delegates
extension SpotifyController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Successfully subscribed to player state")
            }
        })
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }
}

extension SpotifyController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        guard isAddButtonTapped else { return }

        let track = playerState.track
        fetchImageAndAddTrack(for: track)
    }

    private func fetchImageAndAddTrack(for track: SPTAppRemoteTrack) {
        let imageSize = CGSize(width: 300, height: 300)

        appRemote.imageAPI?.fetchImage(forItem: track, with: imageSize) { [weak self] (image, error) in
            guard let self = self else { return }

            var trackImage: Data? = nil

            if let error = error {
                print("Error fetching track image: \(error.localizedDescription)")
            } else if let image = image as? UIImage {
                trackImage = image.jpegData(compressionQuality: 0.5)
            }

            let track = TrackModel(
                id: UUID(),
                trackURI: track.uri,
                trackName: track.name,
                trackArtist: track.artist.name,
                trackImage: trackImage,
                dateCreated: Date.now
            )
            
            self.addTrackToList(track)
        }
    }

    private func addTrackToList(_ track: TrackModel) {
        tracks.append(track)
        isAddButtonTapped = false
    }
}

