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
    var naverMapView: NMFNaverMapView!
    var mapView: NMFMapView {
        return naverMapView.mapView
    }
    var viewModel: MainViewModel?
    var clusterMarkers = [NMFMarker]()
    var clusterObjects = [Cluster]()
    var prevZoomLevel: Double = 18
    let markerFactory = MarkerFactory()
    lazy var dataProvider: PlaceProvider = {
        let provider = PlaceProvider.shared
        provider.fetchedResultsController.delegate = self
        return provider
    }()
    var pullUpVC: DetailPullUpViewController?
    @IBOutlet weak var settingButton: UIButton!
    
    lazy var handler = { (overlay: NMFOverlay?) -> Bool in
        if let marker = overlay as? NMFMarker {
            for cluster in self.clusterObjects {
                if cluster.latitude == marker.position.lat && cluster.longitude == marker.position.lng {
                    self.moveCamera(to: cluster)
                    self.showPullUpVC(with: cluster)
                    break
                }
            }
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //viewModel = MainViewModel(algorithm: ScaleBasedClustering())
        //viewModel = MainViewModel(algorithm: KMeansClustering())
        viewModel = MainViewModel(algorithm: PenaltyKmeans())
        bindViewModel()
        setupMapView()
        if dataProvider.objectCount == 0 {
            dataProvider.insert(completionHandler: handleBatchOperationCompletion)
        }
        self.navigationController?.isNavigationBarHidden = true
        self.view.bringSubviewToFront(settingButton)
        settingButton.layer.cornerRadius = settingButton.bounds.size.width / 2.0
        settingButton.clipsToBounds = true
    }
    
    func setupMapView() {
        naverMapView = NMFNaverMapView(frame: view.frame)
        naverMapView.showZoomControls = true
        naverMapView.showCompass = false
        naverMapView.showLocationButton = false
        naverMapView.showScaleBar = false
        naverMapView.showIndoorLevelPicker = true
        naverMapView.mapView.addCameraDelegate(delegate: self)
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: NMFCameraPosition(NMGLatLng(lat: 37.5656471, lng: 126.9908467), zoom: 18)))
        view.addSubview(naverMapView)
    }
    
    func deleteBeforeMarkers() {
        for clusterMarker in self.clusterMarkers {
            clusterMarker.mapView = nil
        }
        self.clusterMarkers.removeAll()
        self.clusterObjects.removeAll()
    }
    
    func configureNewMarkers(afterClusters: [Cluster]) {
        for cluster in afterClusters {
            let lat = cluster.latitude
            let lng = cluster.longitude
            let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))
            marker.iconImage = NMF_MARKER_IMAGE_BLACK
            if cluster.places.count == 1 {
                marker.iconTintColor = .systemGreen
            } else {
                marker.iconTintColor = .systemRed
            }
            marker.iconImage = markerFactory.makeMarker(markerOverlay: marker, mapView: naverMapView.mapView, placeCount: cluster.places.count)
            marker.zIndex = 1
            marker.mapView = self.mapView
            marker.touchHandler = self.handler
            self.clusterMarkers.append(marker)
            self.clusterObjects.append(cluster)
        }
    }
    
    func bindViewModel() {
        if let viewModel = viewModel {
            viewModel.animationMarkers.bind({ (beforeClusters, afterClusters) in
                DispatchQueue.main.async {
                    self.deleteBeforeMarkers()
                    self.markerAnimation(beforeClusters: beforeClusters, afterClusters: afterClusters)
                }
            })
            
            viewModel.markers.bind({ afterClusters in
                DispatchQueue.main.async {
                    self.deleteBeforeMarkers()
                    self.markerAppearAnimation(clusters: afterClusters)
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
    
    private func moveCamera(to cluster: Cluster) {
        var minLatitude = Double.greatestFiniteMagnitude
        var maxLatitude = Double.leastNormalMagnitude
        var minLongitude = Double.greatestFiniteMagnitude
        var maxLongitude = Double.leastNormalMagnitude
        for place in cluster.places {
            if minLatitude > place.latitude {
                minLatitude = place.latitude
            }
            if maxLatitude < place.latitude {
                maxLatitude = place.latitude
            }
            if minLongitude > place.longitude {
                minLongitude = place.longitude
            }
            if maxLongitude < place.longitude {
                maxLongitude = place.longitude
            }
        }
        let camUpdate = NMFCameraUpdate(fit: NMGLatLngBounds(southWest: NMGLatLng(lat: minLatitude, lng: maxLongitude), northEast: NMGLatLng(lat: maxLatitude, lng: minLongitude)), padding: 50)
        camUpdate.animation = .fly
        camUpdate.animationDuration = 1
        mapView.moveCamera(camUpdate)
    }
    
    private func showPullUpVC(with cluster: Cluster) {
        guard self.pullUpVC == nil else {
            pullUpVC?.cluster = cluster
            return
        }
        guard let pullUpVC: DetailPullUpViewController = storyboard?.instantiateViewController(identifier: DetailPullUpViewController.identifier) as? DetailPullUpViewController else { return }
        self.addChild(pullUpVC)
        let height = view.frame.height * 0.9
        let width = view.frame.width
        pullUpVC.view.frame = CGRect(x: 0, y: view.frame.maxY, width: width, height: height)
        self.view.addSubview(pullUpVC.view)
        pullUpVC.didMove(toParent: self)
        self.pullUpVC = pullUpVC
        self.pullUpVC?.cluster = cluster
        self.pullUpVC?.delegate = self
    }
    
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}

extension UIView {
    func getImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
