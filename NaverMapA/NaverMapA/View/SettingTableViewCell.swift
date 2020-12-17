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
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        titleLabel.textColor = .label
        colorView.isHidden = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            colorView.isHidden = true
            self.titleLabel.text = Setting.Algorithm.allCases[indexPath.row].rawValue
            if InfoSetting.algorithm == "" {
                InfoSetting.algorithm = Setting.Algorithm.allCases[0].rawValue
            }
            if Setting.Algorithm.allCases[indexPath.row].rawValue == InfoSetting.algorithm {
                self.accessoryType = .checkmark
                self.isSelected = false
            } else {
                self.accessoryType = .none
            }
        case 1:
            colorView.isHidden = true
            self.titleLabel.text = Setting.Animation.allCases[indexPath.row].rawValue
            if InfoSetting.animation == "" {
                InfoSetting.animation = Setting.Animation.allCases[0].rawValue
            }
            if Setting.Animation.allCases[indexPath.row].rawValue == InfoSetting.animation {
                self.accessoryType = .checkmark
                self.isSelected = false
            } else {
                self.accessoryType = .none
            }
        case 2:
            colorView.backgroundColor = GetMarkerColor.getColor(
                colorString: Setting.MarkerColor.allCases[indexPath.row].rawValue
            )
            colorView.layer.cornerRadius = 10
            self.titleLabel.text = Setting.MarkerColor.allCases[indexPath.row].rawValue
            self.titleLabel.textColor = GetMarkerColor.getColor(
                colorString: Setting.MarkerColor.allCases[indexPath.row].rawValue
            )
            if InfoSetting.markerColor == "" {
                InfoSetting.markerColor = Setting.MarkerColor.allCases[0].rawValue
            }
            if Setting.MarkerColor.allCases[indexPath.row].rawValue == InfoSetting.markerColor {
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
                InfoSetting.algorithm = Setting.Algorithm.allCases[indexPath.row].rawValue
            case 1:
                InfoSetting.animation = Setting.Animation.allCases[indexPath.row].rawValue
            case 2:
                InfoSetting.markerColor = Setting.MarkerColor.allCases[indexPath.row].rawValue
            default:
                break
            }
        } else {
            self.accessoryType = .none
        }
    }
}
