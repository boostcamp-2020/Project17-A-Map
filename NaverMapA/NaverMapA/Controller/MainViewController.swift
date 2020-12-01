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
    var beforeClusterMarkers = [NMFMarker]()
    var beforeClusters = [Cluster]()
    var prevZoomLevel: Double = 18 {
        didSet(oldValue) {
            if oldValue != mapView.zoomLevel {
                markerAnimation()
            }
        }
    }
    lazy var dataProvider: PlaceProvider = {
        let provider = PlaceProvider.shared
        provider.fetchedResultsController.delegate = self
        return provider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MainViewModel(algorithm: ScaleBasedClustering())
//        viewModel = MainViewModel(algorithm: KMeansClustering())
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
                        self.clusterMarkers.append(marker)
                    }
                    self.prevZoomLevel = self.mapView.zoomLevel
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
    
    private func markerAnimation() {
        for (a, beforeCluster) in beforeClusters.enumerated() {
            for beforePlace in beforeCluster.places {
                guard let currentClusters = viewModel?.markers.value else { return }
                for (c, currentCluster) in currentClusters.enumerated() {
                    if currentCluster.placesDictionary[Point(latitude: beforePlace.latitude, longitude: beforePlace.longitude)] == nil {
                        continue
                    }
                    let startPoint = mapView.projection.point(from: NMGLatLng(lat: beforeClusterMarkers[a].position.lat, lng: beforeClusterMarkers[a].position.lng))
                    let endPoint = mapView.projection.point(from: NMGLatLng(lat: clusterMarkers[c].position.lat, lng: clusterMarkers[c].position.lng))
                    startMarkerAnimation(startPoint: startPoint, endPoint: endPoint, markerOverlay: beforeClusterMarkers[a])
                    break
                }
            }
        }
    }
    
    private func startMarkerAnimation(startPoint: CGPoint, endPoint: CGPoint, markerOverlay: NMFMarker) {
        let markerView = self.view(with: markerOverlay)
        markerView.frame.origin = CGPoint(x: -100, y: -100)
        mapView.addSubview(markerView)
        let markerViewLayer = markerView.layer
        DispatchQueue.global().async {
            CATransaction.begin()
            let markerAnimation = CABasicAnimation(keyPath: "position")
            markerAnimation.duration = 0.4
            markerAnimation.fromValue = CGPoint(x: startPoint.x, y: startPoint.y - (markerView.frame.height/2))
            markerAnimation.toValue = CGPoint(x: endPoint.x, y: endPoint.y - (markerView.frame.height/2))
            CATransaction.setCompletionBlock({
                markerView.removeFromSuperview()
            })
            markerViewLayer.add(markerAnimation, forKey: "position")
            CATransaction.commit()
        }
    }
    
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}
