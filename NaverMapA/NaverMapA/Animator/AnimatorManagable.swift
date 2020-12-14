//
//  AnimatorManager.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/14.
//

import UIKit
import NMapsMap

protocol AnimatorManagable {
    var queue: DispatchQueue { get }
    var group: DispatchGroup { get }
    var isAnimating: Bool { get set }
    var mapView: NMFMapView { get }
    var animationLayer: CALayer { get }
    func appearAnimation(startPoint: CGPoint, cluster: Cluster)
    func movingAnimation(startPoint: CGPoint, endPoint: CGPoint, beforeCluster: Cluster, afterClusters: [Cluster])
    func animateAllMove(before: [Cluster], after: [Cluster])
    func animateAllAppear(after: [Cluster])
    func animate(before: [Cluster], after: [Cluster], type: AnimationType)
}
