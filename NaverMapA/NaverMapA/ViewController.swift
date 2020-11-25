//
//  ViewController.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/17.
//

import UIKit
import NMapsMap
import CoreData

class ViewController: UIViewController {
    
    private var places: [Place]? = []
    
    private lazy var dataProvider: PlaceProvider = {
        let provider = PlaceProvider.shared
        provider.fetchedResultsController.delegate = self
        return provider
    }()
    var mapView: NMFMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = NMFMapView(frame: view.frame)
        mapView.moveCamera(NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(lat: 37.5655271, lng: 126.9904267), zoom: 18)))
        view.addSubview(mapView)
        if dataProvider.objectCount == 0 {
            dataProvider.insert(completionHandler: handleBatchOperationCompletion)
        }
        
        let coordBounds = mapView.projection.latlngBounds(fromViewBounds: UIScreen.main.bounds)
        var datas = [JsonPlace]()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let markers: [NMFMarker] = self.dataProvider.fetch(minLng: coordBounds.southWestLng, maxLng: coordBounds.northEastLng, minLat: coordBounds.southWestLat, maxLat: coordBounds.northEastLat).map {
                datas.append(JsonPlace(place: $0))
                return NMFMarker(position: NMGLatLng(lat: $0.latitude, lng: $0.longitude))
            }
            DispatchQueue.main.async {
                markers.forEach {
                    $0.mapView = self.mapView
                }
                let coord1 = self.mapView.projection.latlng(from: CGPoint(x: 0, y: 0))
                let coord2 = self.mapView.projection.latlng(from: CGPoint(x: 0, y: 100))
                let distance = sqrt(pow(coord1.lat - coord2.lat, 2) + pow(coord1.lng - coord2.lng, 2))
                let scaleBased = ScaleBasedClustering()
                scaleBased.Run(datas: datas, mapScale: distance, completion: { centroids in
                    for centroid in centroids {
                        let lat = centroid.totalLatitude / Double(centroid.clusters.count)
                        let lng = centroid.totalLongitude / Double(centroid.clusters.count)
                        let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))
                        marker.iconImage = NMF_MARKER_IMAGE_BLACK
                        marker.iconTintColor = .red
                        marker.zIndex = 1
                        marker.mapView = self.mapView
                    }
                })
            }
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
    
    private func kMeansClustering(_ datas: [JsonPlace], completion: ([JsonPlace]) -> Void) {
        let K_COUNT = 3
        var centroids = [JsonPlace]()
        (0..<K_COUNT).forEach { centroids.append(datas[$0]) }
        var flag: Bool
        repeat {
            flag = false
            var temp = [[JsonPlace]](repeating: [], count: K_COUNT)
            for i in (0..<datas.count) {
                var minDistance = Double.greatestFiniteMagnitude
                var indexOfNearest = 0
                for (index, centroid) in centroids.enumerated() {
                    let distance = datas[i].distanceTo(centroid)
                    if distance < minDistance {
                        minDistance = distance
                        indexOfNearest = index
                    }
                }
                temp[indexOfNearest].append(datas[i])
            }
            var newCentroids = temp.map {
                JsonPlace.centroid(of: $0)
            }
            newCentroids.sort(by: { $0.longitude < $1.longitude })
            centroids.sort(by: { $0.longitude < $1.longitude })
            if !newCentroids.elementsEqual(centroids) {
                flag = true
                centroids = newCentroids
            }
        } while flag
        completion(centroids)
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}
