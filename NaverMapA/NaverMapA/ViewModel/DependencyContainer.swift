//
//  DependencyContainer.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/14.
//

import UIKit

class DependencyContainer {
    
    func algorithm() -> Clusterable {
        switch Setting.Algorithm(rawValue: InfoSetting.algorithm) {
        case .kims:
            return ScaleBasedClustering()
        case .kmeansPenalty:
            return PenaltyKmeans()
        default:
            return ScaleBasedClustering()
        }
    }
    
    func animation(mapView: NaverMapView, info: MarkerInfo) -> BasicAnimator {
        switch Setting.Animation(rawValue: InfoSetting.animation) {
        case .appleStyle:
            return BasicAnimator(
                mapView: mapView,
                markerInfo: info,
                animationMaker: AnimationMaker(pathMaker: PathMaker())
            )
        case .shootingStart:
            return StarAnimation(
                mapView: mapView,
                markerInfo: info,
                animationMaker: AnimationMaker(pathMaker: PathMaker())
            )
        default:
            return BasicAnimator(
                mapView: mapView,
                markerInfo: info,
                animationMaker: AnimationMaker(pathMaker: PathMaker())
            )
        }
    }
}
