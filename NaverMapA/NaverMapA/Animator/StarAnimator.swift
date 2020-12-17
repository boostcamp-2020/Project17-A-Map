//
//  StarAnimator.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/12.
//

import UIKit
import NMapsMap

final class StarAnimation: BasicAnimator {

    override func movingAnimation(startPoint: CGPoint, endPoint: CGPoint, beforeCluster: Cluster, afterClusters: [Cluster]) {
        let layerWidth = markerInfo.width / 1.4
        let layerHeight = markerInfo.height / 1.4
        let animation = animationMaker.pathScale(start: startPoint, end: endPoint, duration: 0.6, repeatCount: 1, delay: 0)
        let markerLayer = markerFactory.starMarkerLayer(rect: CGRect(x: -100, y: -100, width: layerWidth, height: layerHeight), color: markerInfo.color)
        markerLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
        animationLayer.addSublayer(markerLayer)
        isAnimating = true
        self.group.enter()
        queue.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.group.leave()
                markerLayer.removeFromSuperlayer()
            }
            markerLayer.add(animation, forKey: "")
            CATransaction.commit()
        }
    }
}
