//
//  SettingTableViewCell.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/12/07.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    static let identifier: String = String(describing: SettingTableViewCell.self)

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.titleLabel.text = Setting.Algorithm.allCases[indexPath.row].rawValue
            let value: String = UserDefaults.standard.value(forKey: Setting.State.Algorithm.rawValue) as? String ?? Setting.Algorithm.allCases[0].rawValue
            UserDefaults.standard.setValue(value, forKey: Setting.State.Algorithm.rawValue)
            if Setting.Algorithm.allCases[indexPath.row].rawValue == value {
                self.accessoryType = .checkmark
                self.isSelected = false
            } else {
                self.accessoryType = .none
            }
        case 1:
            self.titleLabel.text = Setting.Animation.allCases[indexPath.row].rawValue
            let value: String = UserDefaults.standard.value(forKey: Setting.State.Animation.rawValue) as? String ?? Setting.Animation.allCases[0].rawValue
            UserDefaults.standard.setValue(value, forKey: Setting.State.Animation.rawValue)
            if Setting.Animation.allCases[indexPath.row].rawValue == value {
                self.accessoryType = .checkmark
                self.isSelected = false
            } else {
                self.accessoryType = .none
            }
        default:
            break
        }
    }
    
    func selectedConfigure(isSelected: Bool, indexPath: IndexPath) {
        if isSelected {
            self.accessoryType = .checkmark
            self.isSelected = false
            switch indexPath.section {
            case 0:
                UserDefaults.standard.setValue(Setting.Algorithm.allCases[indexPath.row].rawValue, forKey: Setting.State.Algorithm.rawValue)
            case 1:
                UserDefaults.standard.setValue(Setting.Animation.allCases[indexPath.row].rawValue, forKey: Setting.State.Animation.rawValue)
            default:
                break
            }
        } else {
            self.accessoryType = .none
        }
    }
}
