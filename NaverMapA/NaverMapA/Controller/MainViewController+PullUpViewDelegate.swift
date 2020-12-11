//
//  MainViewController+PullUpViewDelegate.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/03.
//

import NMapsMap

extension MainViewController: PullUpViewDelegate {
    
    func move(toLat lat: Double, lng: Double) {
        self.naverMapView.selectedLeapMarker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))
        naverMapView.moveCamera(to: BasicCluster(latitude: lat, longitude: lng, places: [], placesDictionary: [:])) {
        }
        DispatchQueue.main.async {
            if self.naverMapView.selectedLeapMarker != nil {
                self.flashAnimator.run()
            } else {
                self.flashAnimator.stop()
            }
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
