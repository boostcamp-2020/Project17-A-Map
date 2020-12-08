//
//  SettingTableViewController.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/12/07.
//

import UIKit
struct Setting {
    enum State: String, CaseIterable {
        case Algorithm = "알고리즘"
        case Animation = "애니메이션"
    }
    enum Algorithm: String, CaseIterable {
        case kims = "Kim's Algorithm"
        case kmeansElbow = "K-means with Elbow"
        case kmeansPenalty = "Penalty K-means"
    }
    enum Animation: String, CaseIterable {
        case appleStyle = "Apple Style"
        case shootingStart = "ShootingStar"
    }
}

class SettingTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: SettingTableViewCell.identifier, bundle: .main), forCellReuseIdentifier: SettingTableViewCell.identifier)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Setting.State.allCases.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Setting.Algorithm.allCases.count
        case 1:
            return Setting.Animation.allCases.count
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
            cell.titleLabel.text = Setting.Algorithm.allCases[indexPath.row].rawValue
            let value: String = UserDefaults.standard.value(forKey: Setting.State.Algorithm.rawValue) as? String ?? Setting.Algorithm.allCases[0].rawValue
            UserDefaults.standard.setValue(value, forKey: Setting.State.Algorithm.rawValue)
            if Setting.Algorithm.allCases[indexPath.row].rawValue == value {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        case 1:
            cell.titleLabel.text = Setting.Animation.allCases[indexPath.row].rawValue
            let value: String = UserDefaults.standard.value(forKey: Setting.State.Animation.rawValue) as? String ?? Setting.Animation.allCases[0].rawValue
            UserDefaults.standard.setValue(value, forKey: Setting.State.Animation.rawValue)
            if Setting.Animation.allCases[indexPath.row].rawValue == value {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        default:
            break
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in 0..<tableView.numberOfRows(inSection: indexPath.section) {
            guard let cell: UITableViewCell = tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section) as IndexPath) else {
                return
            }
            if i == indexPath.row {
                cell.accessoryType = .checkmark
                cell.isSelected = false
                switch indexPath.section {
                case 0:
                    UserDefaults.standard.setValue(Setting.Algorithm.allCases[indexPath.row].rawValue, forKey: Setting.State.Algorithm.rawValue)
                case 1:
                    UserDefaults.standard.setValue(Setting.Animation.allCases[indexPath.row].rawValue, forKey: Setting.State.Animation.rawValue)
                default:
                    break
                }
            } else {
                cell.accessoryType = .none
            }
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Setting.State.allCases[section].rawValue
    }
}
