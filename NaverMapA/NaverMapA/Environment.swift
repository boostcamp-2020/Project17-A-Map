//
//  Environment.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/17.
//

import Foundation

public enum Environment {

    enum Keys {
      enum Plist {
        static let clientId = "CLIENT_ID"
      }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let clientId: String = {
        guard let id = Environment.infoDictionary[Keys.Plist.clientId] as? String else {
            fatalError("API Key not set in plist for this environment")
        }
        return id
    }()
}
