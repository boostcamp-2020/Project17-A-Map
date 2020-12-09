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
    
    var naverMapView: NaverMapView!
    var mapView: NMFMapView { naverMapView.mapView }
    var animationLayer: CALayer { naverMapView.animationLayer }
    var viewModel: MainViewModel?
    lazy var dataProvider: PlaceProvider = {
        let provider = PlaceProvider.shared
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
            AlertManager.shared.clientIdIsNil(controller: self)
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
        naverMapView = NaverMapView(frame: view.frame)
        naverMapView.mapView.addCameraDelegate(delegate: self)
        naverMapView.naverMapDelegate = self
        view.addSubview(naverMapView)
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
    
    private func coreDataUpdateHandler(result: Error?) {
        if result == nil {
            updateMapView()
        }
    }

    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.animationMarkers.bind { (beforeClusters, afterClusters) in
            viewModel.animationQueue.addOperation {
                self.naverMapView.deleteBeforeMarkers()
                self.naverMapView.clusterObjects = afterClusters
            }
            viewModel.animationQueue.addOperation(MoveAnimator(mapView: self.mapView, animationLayer: self.animationLayer, beforeClusters: beforeClusters, afterClusters: afterClusters, handler: self.naverMapView.configureNewMarker))
        }

        viewModel.markers.bind { afterClusters in
            viewModel.animationQueue.addOperation {
                self.naverMapView.deleteBeforeMarkers()
                self.naverMapView.clusterObjects = afterClusters
            }

            viewModel.animationQueue.addOperation(AppearAnimator(mapView: self.mapView, animationLayer: self.animationLayer, clusters: afterClusters, handler: self.naverMapView.configureNewMarker))
        }
    }
    
    private func handleBatchOperationCompletion(error: Error?) {
        if let error = error {
            AlertManager.shared.coreDataBatchError(controller: self, message: error.localizedDescription)
        } else {
            dataProvider.resetAndRefetch()
        }
    }
    
    func showPullUpVC(with cluster: Cluster) {
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

extension MainViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        animationLayer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        viewModel?.queue.cancelAllOperations()
        viewModel?.animationQueue.cancelAllOperations()
    }
}

extension MainViewController: NaverMapViewDelegate {
    func naverMapView(_ mapView: NaverMapView, markerDidSelected cluster: Cluster) {
        self.showPullUpVC(with: cluster)
    }
    
    func naverMapView(_ mapView: NaverMapView, markerWillAdded latlng: NMGLatLng) {
        let title = "마커 추가"
        let message = "마커를 추가하시겠습니까"
        let okHandler: (UIAlertAction) -> Void = { [weak self] _ in
            guard let self = self else { return }
            self.dataProvider.insertPlace(latitide: latlng.lat, longitude: latlng.lng, completionHandler: self.coreDataUpdateHandler)
        }
        AlertManager.shared.okCancle(controller: self, title: title, message: message, okHandler: okHandler, cancleHandler: nil)
    }
    
    func naverMapView(_ mapView: NaverMapView, markerWillDeleted place: Place) {
        let title = "마커 삭제"
        let message = "마커를 삭제하시겠습니까"
        let okHandler: (UIAlertAction) -> Void = { [weak self] _ in
            guard let self = self else { return }
            self.dataProvider.delete(object: place, completionHandler: self.coreDataUpdateHandler)
        }
        AlertManager.shared.okCancle(controller: self, title: title, message: message, okHandler: okHandler, cancleHandler: nil)
    }
}
