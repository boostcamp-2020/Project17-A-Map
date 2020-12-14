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
        case Setting.MarkerColor.indigo.rawValue:
            return .systemIndigo
        case Setting.MarkerColor.pink.rawValue:
            return .systemPink
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
        case Setting.MarkerColor.color1.rawValue:
            return UIColor(red: 239/255, green: 194/255, blue: 150/255, alpha: 1)
        case Setting.MarkerColor.color2.rawValue:
            return UIColor(red: 181/255, green: 225/255, blue: 232/255, alpha: 1)
        case Setting.MarkerColor.color3.rawValue:
            return UIColor(red: 233/255, green: 175/255, blue: 185/255, alpha: 1)
        case Setting.MarkerColor.color4.rawValue:
            return UIColor(red: 108/255, green: 153/255, blue: 202/255, alpha: 1)
        default:
            return .systemTeal
        }
    }
}
