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
    var clusterMarkers = [NMFMarker]()
    var markersAnimation: [UIViewPropertyAnimator] = [] // 추후 애니메이션을 제어하기 위한 배열
    private lazy var dataProvider: PlaceProvider = {
        let provider = PlaceProvider.shared
        provider.fetchedResultsController.delegate = self
        return provider
    }()
    
    private lazy var handler = { (overlay: NMFOverlay?) -> Bool in
        if let marker = overlay as? NMFMarker {
            self.moveCamera(to: marker)
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        viewModel = MainViewModel(algorithm: ScaleBasedClustering())
        viewModel = MainViewModel(algorithm: KMeansClustering())
        bindViewModel()
        setupMapView()
        if dataProvider.objectCount == 0 {
            dataProvider.insert(completionHandler: handleBatchOperationCompletion)
        }
    }
    
    func setupMapView() {
        mapView = NMFMapView(frame: view.frame)
        mapView.addCameraDelegate(delegate: self)
        mapView.moveCamera(NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(lat: 37.5655271, lng: 126.9904267), zoom: 18)))
        view.addSubview(mapView)
    }
    
    func bindViewModel() {
        if let viewModel = viewModel {
            viewModel.markers.bind({ _ in
                // rendering
                DispatchQueue.main.async {
                    for clusterMarker in self.clusterMarkers {
                        clusterMarker.mapView = nil
                    }
                    self.clusterMarkers.removeAll()
                    self.markerAnimation(clusterArray: viewModel.markers.value)
                    for cluster in viewModel.markers.value {
                        let lat = cluster.latitude
                        let lng = cluster.longitude
                        let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))
                        marker.iconImage = NMF_MARKER_IMAGE_BLACK
                        if cluster.places.count == 1 {
                            marker.iconTintColor = .green
                        } else {
                            marker.iconTintColor = .red
                        }
                        marker.captionText = "\(cluster.places.count)"
                        marker.zIndex = 1
                        marker.mapView = self.mapView
                        marker.touchHandler = self.handler
                        self.clusterMarkers.append(marker)
                    }
                }
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
        }
    }
    
    private func markerAnimation(clusterArray: [Cluster]) {
        //화면에 존재하던 마커들만이 아닌, 군집에 속한 마커들이 모두 애니메이션이 된다. Cluster 구조를 개선할 필요가 있음.
        clusterArray.forEach { cluster in
            let endPoint = mapView.projection.point(from: NMGLatLng(lat: cluster.latitude, lng: cluster.longitude))
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
    
    private func moveCamera(to marker: NMFMarker) {
        mapView.moveCamera(NMFCameraUpdate(position: NMFCameraPosition(marker.position, zoom: 21)))
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
            let bounds = CoordinateBounds(southWestLng: coordBounds.southWestLng,
                                          northEastLng: coordBounds.northEastLng,
                                          southWestLat: coordBounds.southWestLat,
                                          northEastLat: coordBounds.northEastLat)
            
            let places = self.dataProvider.fetch(bounds: bounds)
            self.viewModel?.updatePlaces(places: places, bounds: bounds)
        }
    }
}
