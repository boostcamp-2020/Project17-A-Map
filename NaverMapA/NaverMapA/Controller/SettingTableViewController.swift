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
        cell.configure(indexPath: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for index in 0..<tableView.numberOfRows(inSection: indexPath.section) {
            guard let cell: SettingTableViewCell = tableView.cellForRow(at: IndexPath(row: index, section: indexPath.section) as IndexPath) as? SettingTableViewCell else {
                return
            }
            cell.selectedConfigure(isSelected: index == indexPath.row, indexPath: indexPath)
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Setting.State.allCases[section].rawValue
    }
}
