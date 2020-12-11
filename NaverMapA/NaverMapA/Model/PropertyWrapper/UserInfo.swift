//
//  UserInfo.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/08.
//

import Foundation

@propertyWrapper
struct UserInfo {
    
    private let key: String
 
    var wrappedValue: String {
        get { UserDefaults.standard.string(forKey: key) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
 
    init(key: String) {
        self.key = key
    }
}

struct InfoSetting {
    @UserInfo(key: "algorithm") static var algorithm: String
    @UserInfo(key: "animation") static var animation: String
    @UserInfo(key: "markerColor") static var markerColor: String
}
