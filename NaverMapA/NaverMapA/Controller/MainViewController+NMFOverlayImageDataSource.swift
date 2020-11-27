//
//  MainViewController+NMFOverlayImageDataSource.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/11/26.
//

import Foundation
import NMapsMap

extension MainViewController: NMFOverlayImageDataSource {
    
    func view(with overlay: NMFOverlay) -> UIView {
        let markerOverlay = overlay as? NMFMarker
        let markerView = UIImageView(frame: CGRect(x: 0, y: 0, width: markerOverlay?.iconImage.imageWidth ?? 0, height: markerOverlay?.iconImage.imageHeight ?? 0))
        markerView.image = markerOverlay?.iconImage.image
        return markerView
    }
}
