//
//  Contact.swift
//  Uttcha
//
//  Created by KHJ on 6/24/24.
//

import Foundation

struct ContactModel {
    let id = UUID()
    var familyName: String
    var givenName: String
    var phoneNumber: String?
    var imageData: Data?
}
