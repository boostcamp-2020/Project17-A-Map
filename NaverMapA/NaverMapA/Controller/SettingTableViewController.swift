//
//  SettingTableViewController.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/12/07.
//

import UIKit
struct Setting {
    enum State: String {
        case Algorithm
        case Animation
    }
}

class SettingTableViewController: UITableViewController {
    private let settingMenuTitle = ["알고리즘", "애니메이션"]
    private let algorithmTitle = ["Kim's Algorithm", "K-means with Elbow", "Penalty K-means"]
    private let animationTitle = ["Apple Style", "ShootingStar"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: SettingTableViewCell.identifier, bundle: .main), forCellReuseIdentifier: SettingTableViewCell.identifier)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for section in 0..<settingMenuTitle.count {
            for i in 0..<tableView.numberOfRows(inSection: section) {
                var index = 0
                switch section {
                case 0:
                    index = UserDefaults.standard.value(forKey: Setting.State.Algorithm.rawValue) as? Int ?? 0
                case 1:
                    index = UserDefaults.standard.value(forKey: Setting.State.Animation.rawValue) as? Int ?? 0
                default:
                    break
                }
                let cell: UITableViewCell = tableView.cellForRow(at: NSIndexPath(row: i, section: section) as IndexPath)!
                if i == index {
                    cell.accessoryType = .checkmark
                    cell.isSelected = false
                    switch section {
                    case 0:
                        UserDefaults.standard.setValue(index, forKey: Setting.State.Algorithm.rawValue)
                    case 1:
                        UserDefaults.standard.setValue(index, forKey: Setting.State.Animation.rawValue)
                    default:
                        break
                    }
                } else {
                    cell.accessoryType = .none
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingMenuTitle.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return algorithmTitle.count
        case 1:
            return animationTitle.count
        default:
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell else {
            return UITableViewCell()
        }
        switch indexPath.section {
        case 0:
            cell.titleLabel.text = algorithmTitle[indexPath.row]
        case 1:
            cell.titleLabel.text = animationTitle[indexPath.row]
        default:
            break
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in 0..<tableView.numberOfRows(inSection: indexPath.section) {
            let cell: UITableViewCell = tableView.cellForRow(at: NSIndexPath(row: i, section: indexPath.section) as IndexPath)!
            if i == indexPath.row {
                cell.accessoryType = .checkmark
                cell.isSelected = false
                switch indexPath.section {
                case 0:
                    UserDefaults.standard.setValue(indexPath.row, forKey: Setting.State.Algorithm.rawValue)
                case 1:
                    UserDefaults.standard.setValue(indexPath.row, forKey: Setting.State.Animation.rawValue)
                default:
                    break
                }
            } else {
                cell.accessoryType = .none
            }
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingMenuTitle[section]
    }
}
