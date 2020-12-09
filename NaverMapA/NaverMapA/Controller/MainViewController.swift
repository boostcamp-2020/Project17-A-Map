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
    
    // MARK: - Properties
    
    var naverMapView: MyNaverMapView!
    var mapView: NMFMapView { naverMapView.mapView }
    var animationLayer: CALayer { naverMapView.animationLayer }

    var viewModel: MainViewModel?
    var prevZoomLevel: Double = 18
    lazy var dataProvider: PlaceProvider = {
        let provider = PlaceProvider.shared
        provider.fetchedResultsController.delegate = self
        return provider
    }()
    var pullUpVC: DetailPullUpViewController?

    @IBOutlet weak var settingButton: UIButton!
    
    // MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        setUpCoreData()
        setUpOtherViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let _ = NMFAuthManager.shared().clientId else {
            let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }
            showAlert(title: "에러", message: "ClientID가 없습니다.", preferredStyle: UIAlertController.Style.alert, actions: [okAction])
            return
        }
        self.navigationController?.isNavigationBarHidden = true
        self.view.bringSubviewToFront(settingButton)
        switch UserDefaults.standard.value(forKey: Setting.State.Algorithm.rawValue) as? String ?? "" {
        case Setting.Algorithm.kims.rawValue:
            viewModel = MainViewModel(algorithm: ScaleBasedClustering())
        case Setting.Algorithm.kmeansElbow.rawValue:
            viewModel = MainViewModel(algorithm: KMeansClustering())
        case Setting.Algorithm.kmeansPenalty.rawValue:
            viewModel = MainViewModel(algorithm: PenaltyKmeans())
        default:
            viewModel = MainViewModel(algorithm: ScaleBasedClustering())
        }
        bindViewModel()
        updateMapView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Initailize

    private func setUpMapView() {
        naverMapView = MyNaverMapView(frame: view.frame)
        naverMapView.mapView.addCameraDelegate(delegate: self)
        view.addSubview(naverMapView)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        naverMapView.mapView.addGestureRecognizer(longPressGesture)
    }
    
    private func setUpCoreData() {
        if dataProvider.objectCount == 0 {
            dataProvider.insert(completionHandler: handleBatchOperationCompletion)
        }
    }
    
    private func setUpOtherViews() {
        settingButton.layer.cornerRadius = settingButton.bounds.size.width / 2.0
        settingButton.clipsToBounds = true
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    // MARK: - Methods
    
    private func addMarker(latlng: NMGLatLng) {
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.dataProvider.insertPlace(latitide: latlng.lat, longitude: latlng.lng, completionHandler: self.coreDataUpdateHandler)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        showAlert(title: "마커 추가", message: "마커를 추가하시겠습니까?", preferredStyle: .alert, actions: [okAction, cancelAction])
    }
    
    private func deleteMarker(marker: NMFMarker) {
        for cluster in naverMapView.clusterObjects {
            if cluster.latitude == marker.position.lat && cluster.longitude == marker.position.lng && cluster.places.count == 1 {
                let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.dataProvider.delete(object: cluster.places[0], completionHandler: self.coreDataUpdateHandler)
                }
                let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                showAlert(title: "마커 삭제", message: "마커를 삭제하시겠습니까?", preferredStyle: .alert, actions: [okAction, cancelAction])
                break
            }
        }
    }
    
    private func coreDataUpdateHandler(result: Error?) {
        if result == nil {
            updateMapView()
        }
    }
    
    private func deleteBeforeMarkers() {
        for clusterMarker in naverMapView.clusterMarkers {
            clusterMarker.mapView = nil
        }
        naverMapView.clusterMarkers.removeAll()
        naverMapView.clusterObjects.removeAll()
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.animationMarkers.bind { (beforeClusters, afterClusters) in
            viewModel.animationQueue.addOperation {
                self.deleteBeforeMarkers()
                self.naverMapView.clusterObjects = afterClusters
            }
            viewModel.animationQueue.addOperation(MoveAnimator(mapView: self.mapView, animationLayer: self.animationLayer, beforeClusters: beforeClusters, afterClusters: afterClusters, handler: self.naverMapView.configureNewMarker))
        }
        
        viewModel.markers.bind { afterClusters in
            viewModel.animationQueue.addOperation {
                self.deleteBeforeMarkers()
                self.naverMapView.clusterObjects = afterClusters
            }

            viewModel.animationQueue.addOperation(AppearAnimator(mapView: self.mapView, animationLayer: self.animationLayer, clusters: afterClusters, handler: self.naverMapView.configureNewMarker))
        }
    }
    
    private func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        actions.forEach {
            alert.addAction($0)
        }
        present(alert, animated: false, completion: nil)
    }
    
    private func handleBatchOperationCompletion(error: Error?) {
        if let error = error {
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            showAlert(title: "Executing batch operation error!", message: error.localizedDescription, preferredStyle: .alert, actions: [okAction])
        } else {
            dataProvider.resetAndRefetch()
        }
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
    
    @objc private func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let currentPoint: CGPoint = sender.location(in: mapView)
            let latlng = mapView.projection.latlng(from: currentPoint)
            guard let marker = mapView.pick(currentPoint) as? NMFMarker else {
                addMarker(latlng: latlng)
                return
            }
            deleteMarker(marker: marker)
        }
    }
    
}

extension MainViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        animationLayer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        viewModel?.queue.cancelAllOperations()
        viewModel?.animationQueue.cancelAllOperations()
    }
}
