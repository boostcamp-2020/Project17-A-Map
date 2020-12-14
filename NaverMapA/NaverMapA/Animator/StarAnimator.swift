//
//  StarAnimator.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/12.
//

import UIKit
import NMapsMap

class StarAnimation: BasicAnimator {

    override func movingAnimation(startPoint: CGPoint, endPoint: CGPoint, beforeCluster: Cluster, afterClusters: [Cluster]) {
        let layerWidth = NMFMarker().iconImage.imageWidth
        let layerHeight = NMFMarker().iconImage.imageHeight
        let animation = animationMaker.pathScale(start: startPoint, end: endPoint, duration: 0.6, repeatCount: 1, delay: 0)
        let markerLayer = markerFactory.starMarkerLayer(rect: CGRect(x: -100, y: -100, width: layerWidth, height: layerHeight), color: markerColor)
        markerLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
        animationLayer.addSublayer(markerLayer)
        isAnimating = true
        count += 1
        queue.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.count -= 1
                markerLayer.removeFromSuperlayer()
                if self.count == 0 && self.isAnimating {
                    self.isAnimating = false
                    self.moveCompletionHandler(afterClusters, self.markerColor)
                }
            }
            markerLayer.add(animation, forKey: "")
            CATransaction.commit()
        }
    }
}
