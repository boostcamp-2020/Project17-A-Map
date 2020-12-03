//
//  MarkerFactory.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/12/03.
//

import UIKit
import NMapsMap

class MarkerFactory {
    func makeMarker(markerOverlay: NMFOverlay, mapView: NMFMapView, placeCount: Int) -> NMFOverlayImage {
        let markerOverlay = markerOverlay as? NMFMarker
        let markerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: markerOverlay?.iconImage.imageWidth ?? 0, height: markerOverlay?.iconImage.imageHeight ?? 0))
        markerImageView.image = markerOverlay?.iconImage.image
        let label = UILabel()
        label.clipsToBounds = true
        label.text = "\(placeCount)"
        label.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        label.textAlignment = NSTextAlignment.center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        label.backgroundColor = .white
        markerImageView.addSubview(label)
        setLayout(label: label, markerImageView: markerImageView)
        mapView.addSubview(markerImageView)
        let image = markerImageView.asImage()
        let markerImage = NMFOverlayImage(image: image)
        markerImageView.removeFromSuperview()
        return markerImage
    }
    
    func setLayout(label: UILabel, markerImageView: UIImageView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 10
        label.leadingAnchor.constraint(equalTo: markerImageView.leadingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: markerImageView.trailingAnchor, constant: -8).isActive = true
        label.topAnchor.constraint(equalTo: markerImageView.topAnchor, constant: 8).isActive = true
        label.bottomAnchor.constraint(equalTo: markerImageView.bottomAnchor, constant: -18).isActive = true
    }
}

