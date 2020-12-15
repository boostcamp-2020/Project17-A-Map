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
        case MarkerColor = "마커색상"
    }
    
    enum Algorithm: String, CaseIterable {
        case kims = "Kim's Algorithm"
        case kmeansPenalty = "Penalty K-means"
    }
    
    enum Animation: String, CaseIterable {
        case appleStyle = "Apple Style"
        case shootingStart = "ShootingStar"
    }
    
    enum MarkerColor: String, CaseIterable {
        case indigo = "인디고"
        case pink = "핑크색"
        case yellow = "노랑색"
        case blue = "파랑색"
        case green = "초록색"
        case purple = "보라색"
        case gray = "회색"
        case teal = "하늘색"
        case color1 = "color1"
        case color2 = "color2"
        case color3 = "color3"
        case color4 = "color4"
    }
}

class SettingTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: SettingTableViewCell.identifier, bundle: .main), forCellReuseIdentifier: SettingTableViewCell.identifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
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
        case 2:
            return Setting.MarkerColor.allCases.count
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
