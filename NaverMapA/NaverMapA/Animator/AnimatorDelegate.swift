//
//  AnimatorDelegate.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/14.
//

import UIKit

protocol AnimatorDelegate: class {
    func animator(_ animator: AnimatorManagable, didAppeared cluster: Cluster, color: UIColor)
    func animator(_ animator: AnimatorManagable, didMoved clusters: [Cluster], color: UIColor)
}
