//
//  Environment.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/17.
//

import Foundation

public enum Environment {

    enum Keys {
        static let clientId = "CLIENT_ID"
        static let clientSecret = "CLIENT_SECRET"
    }
    private static let infoDictionary: [String: Any]? = {
        guard let dict = Bundle.main.infoDictionary else {
            return nil
        }
        return dict
    }()
    static let clientId: String? = {
        guard let id = Environment.infoDictionary?[Keys.clientId] as? String else {
            return nil
        }
        return id
    }()
    static let clientSecret: String? = {
        guard let secret = Environment.infoDictionary?[Keys.clientSecret] as? String else {
            return nil
        }
        return secret
    }()
}
