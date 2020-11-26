//
//  ViewController.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/17.
//

import UIKit
import NMapsMap
import CoreData

class MainViewController: UIViewController {
        
    var mapView: NMFMapView!
    var viewModel: MainViewModel?
    var markersAnimation: [UIViewPropertyAnimator] = [] // 추후 애니메이션을 제어하기 위한 배열
    private lazy var dataProvider: PlaceProvider = {
        let provider = PlaceProvider.shared
        provider.fetchedResultsController.delegate = self
        return provider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MainViewModel(algorithm: MockCluster())
        bindViewModel()
        mapView = NMFMapView(frame: view.frame)
        mapView.addCameraDelegate(delegate: self)
        view.addSubview(mapView)
        mapView.moveCamera(NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(lat: 37.5655271, lng: 126.9904267), zoom: 18)))
        if dataProvider.objectCount == 0 {
            dataProvider.insert(completionHandler: handleBatchOperationCompletion)
        }
        
    }
    
    func bindViewModel() {
        if let viewModel = viewModel {
            viewModel.markers.bind({ (markers) in
                // rendering
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let _ = NMFAuthManager.shared().clientId else {
            let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }
            showAlert(title: "에러", message: "ClientID가 없습니다.", preferredStyle: UIAlertController.Style.alert, action: okAction)
            return
        }
    }
    
    // MARK: - Methods
    
    func setMarkers() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let markers = self.dataProvider.fetchAll().map {
                return NMFMarker(position: NMGLatLng(lat: $0.latitude, lng: $0.longitude))
            }
            DispatchQueue.main.async {
                markers.forEach {
                    $0.mapView = self.mapView
                }
            }
        }
    }
    
    private func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style, action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(action)
        present(alert, animated: false, completion: nil)
    }
    
    private func handleBatchOperationCompletion(error: Error?) {
        if let error = error {
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            showAlert(title: "Executing batch operation error!", message: error.localizedDescription, preferredStyle: .alert, action: okAction)
        } else {
            dataProvider.resetAndRefetch()
            setMarkers()
        }
    }
    
    private func markerAnimation(clusterArray: [Cluster]) {
        clusterArray.forEach { cluster in
            let endPoint = mapView.projection.point(from: NMGLatLng(lat: cluster.latitude, lng: cluster.longigude))
            
            cluster.places.forEach { place in
                var startPoint = self.mapView.projection.point(from: NMGLatLng(lat: place.latitude, lng: place.longitude))
                let markerView = self.view(with: NMFMarker())
                startPoint.x -= (markerView.frame.width / 2)
                startPoint.y -= markerView.frame.height
                markerView.frame.origin = startPoint
                self.mapView.addSubview(markerView)
                let markerAnimation = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                    markerView.frame.origin = CGPoint(x: endPoint.x - (markerView.frame.width / 2), y: endPoint.y - markerView.frame.height)
                }, completion: { _ in
                    markerView.removeFromSuperview()
                })
                markerAnimation.startAnimation()
                //markerAnimation.stopAnimation(false)
                //markerAnimation.finishAnimation(at: .current)
            }
        }
    }
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}

extension MainViewController: NMFMapViewCameraDelegate {
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let coordBounds = mapView.projection.latlngBounds(fromViewBounds: UIScreen.main.bounds)
        
        DispatchQueue.global().async {
            let places = self.dataProvider.fetch(minLng: coordBounds.southWestLng,
                                                 maxLng: coordBounds.northEastLng,
                                                 minLat: coordBounds.southWestLat,
                                                 maxLat: coordBounds.northEastLat)
            self.viewModel?.updatePlaces(places: places)
        }
    }
}
