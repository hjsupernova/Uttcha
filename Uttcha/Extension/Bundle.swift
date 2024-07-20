//
//  Bundle.swift
//  Uttcha
//
//  Created by KHJ on 7/20/24.
//

import Foundation

extension Bundle {

    var spotifyClientID: String {
        guard let filePath = Bundle.main.path(forResource: "SecureAPIKeys", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Couldn't find file 'SecureAPIKeys.plist'.")
        }

        // plist 안쪽에 사용할 Key값을 입력해주세요.
        guard let value = plistDict.object(forKey: "spotifyClientID") as? String else {
            fatalError("Couldn't find key 'API_Key' in 'SecureAPIKeys.plist'.")
        }

        return value
    }
}
