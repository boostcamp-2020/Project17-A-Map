//
//  MainViewController+PullUpViewDelegate.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/03.
//

import NMapsMap

extension MainViewController: PullUpViewDelegate {
    
    func move(toLat lat: Double, lng: Double) {
        let camUpdate = NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(lat: lat - 0.00001, lng: lng), zoom: 20))
        camUpdate.animation = .fly
        camUpdate.animationDuration = 2
        mapView.moveCamera(camUpdate) { [weak self] _ in
            guard let self = self else { return }
            self.naverMapView.selectedLeafMarker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))
        }
    }
    
    func dismissPullUpVC() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.pullUpVC?.view.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height)
        }, completion: { _ in
            self.pullUpVC?.willMove(toParent: nil)
            self.pullUpVC?.view.removeFromSuperview()
            self.pullUpVC?.removeFromParent()
            self.pullUpVC?.dismiss(animated: false, completion: nil)
            self.pullUpVC = nil
        })
    }
    
}
