//
//  MusicModel.swift
//  Uttcha
//
//  Created by KHJ on 7/22/24.
//

import Foundation

struct TrackModel: Identifiable {
    let id: UUID
    let trackURI: String
    let trackName: String
    let trackArtist: String
    let trackImage: Data?
    let dateCreated: Date
}
