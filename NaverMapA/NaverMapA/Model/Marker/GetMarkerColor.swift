//
//  GetMarkerColor.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/12/10.
//

import Foundation
import UIKit

class GetMarkerColor {
    static func getColor(colorString: String) -> UIColor {
        switch colorString {
        case Setting.MarkerColor.red.rawValue:
            return .systemRed
        case Setting.MarkerColor.blue.rawValue:
            return .systemBlue
        case Setting.MarkerColor.yellow.rawValue:
            return .systemYellow
        case Setting.MarkerColor.purple.rawValue:
            return .systemPurple
        case Setting.MarkerColor.green.rawValue:
            return .systemGreen
        case Setting.MarkerColor.gray.rawValue:
            return .systemGray
        case Setting.MarkerColor.teal.rawValue:
            return .systemTeal
        default:
            return .systemTeal
        }
    }
}
