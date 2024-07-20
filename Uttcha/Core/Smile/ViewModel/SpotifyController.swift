//
//  SpotifyController.swift
//  Uttcha
//
//  Created by KHJ on 7/20/24.
//

import Combine
import Foundation

import SpotifyiOS

class SpotifyController: NSObject, ObservableObject {
    static private let kAccessTokenKey = "access-token-key"
    let spotifyClientID = Bundle.main.spotifyClientID
    let spotifyRedirectURL = URL(string:"spotify-ios-quick-start://spotify-login-callback")!
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.setValue(accessToken, forKey: SpotifyController.kAccessTokenKey)
        }
    }
    var playURI = ""

    private var connectCancellable: AnyCancellable?
    private var disconnectCancellable: AnyCancellable?

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

    lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID,
        redirectURL: spotifyRedirectURL
    )

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    func setAccessToken(from url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)

        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print(errorDescription)
        }
    }

    func authorize() {
        self.appRemote.authorizeAndPlayURI("")
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

    func open() {
        if let url = URL(string: "spotify://"),             UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

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
    }
}
