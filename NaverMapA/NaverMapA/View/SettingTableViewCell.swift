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
    
}
