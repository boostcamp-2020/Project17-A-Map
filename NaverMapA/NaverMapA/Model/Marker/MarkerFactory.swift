//
//  MarkerFactory.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/12/03.
//

import Foundation
import NMapsMap

class MarkerFactory {
    func makeMarker(markerOverlay: NMFOverlay, mapView: NMFMapView, placeCount: Int) -> NMFOverlayImage {
        let markerOverlay = markerOverlay as? NMFMarker
        let markerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: markerOverlay?.iconImage.imageWidth ?? 0, height: markerOverlay?.iconImage.imageHeight ?? 0))
        markerImageView.image = markerOverlay?.iconImage.image
        let label = UILabel()
        label.clipsToBounds = true
        label.layer.cornerRadius = 8
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(placeCount)"
        label.textColor = .white
        label.backgroundColor = .black
        markerImageView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: markerImageView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: markerImageView.centerYAnchor).isActive = true
        mapView.addSubview(markerImageView)
        let image = markerImageView.asImage()
        let markerImage = NMFOverlayImage(image: image)
        markerImageView.removeFromSuperview()
        return markerImage
    }
}
