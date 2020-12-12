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
    var fetchBtn: FetchButton!
    var animator: MoveAnimator1!
    @Unit(wrappedValue: 18, threshold: 0.5) var zoomLevelCheck
    
    @IBOutlet weak var settingButton: UIButton!
    
    // MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        setUpCoreData()
        setUpOtherViews()
        let markerColor = GetMarkerColor.getColor(colorString: InfoSetting.markerColor)
        animator = MoveAnimator1(
            mapView: self.naverMapView,
            markerColor: markerColor,
            appearCompletionHandler: self.naverMapView.configureNewMarker(afterCluster:markerColor:),
            moveCompletionHandler: self.naverMapView.configureNewMarkers(afterClusters:markerColor:)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.bringSubviewToFront(settingButton)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let _ = NMFAuthManager.shared().clientId else {
            AlertManager.shared.clientIdIsNil(controller: self)
            return
        }
        switch InfoSetting.algorithm {
        case Setting.Algorithm.kims.rawValue:
            viewModel = MainViewModel(algorithm: ScaleBasedClustering())
        case Setting.Algorithm.kmeansElbow.rawValue:
            viewModel = MainViewModel(algorithm: KMeansClustering())
        case Setting.Algorithm.kmeansPenalty.rawValue:
            viewModel = MainViewModel(algorithm: PenaltyKmeans())
        default:
            viewModel = MainViewModel(algorithm: ScaleBasedClustering())
        }
        animator.markerColor = GetMarkerColor.getColor(colorString: InfoSetting.markerColor)
        bindViewModel()
        updateMapView()
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
        settingButton.layer.shadowColor = UIColor.black.cgColor
        settingButton.layer.shadowOpacity = 0.4
        settingButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
        setupFetchButton()
    }
    
    func setupFetchButton() {
        fetchBtn = FetchButton(frame: CGRect(x: 80, y: 100, width: 140, height: 40))
        view.addSubview(fetchBtn)
        fetchBtn.addTarget(self, action: #selector(fetchDidTouched), for: .touchDown)
        fetchBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fetchBtn.widthAnchor.constraint(equalToConstant: 140),
            fetchBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fetchBtn.heightAnchor.constraint(equalToConstant: 40),
            fetchBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
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
            DispatchQueue.main.async {
                if self.animator.isAnimating { // 애니메이션중일때
//                    print("애니메이션중..")
                    // 1. 애니메이션중인 레이어 모두 지우기
                    self.animator.isAnimating = false // 새로운 마커를 그리지 않음
                    self.animationLayer.sublayers?.removeAll()
                    // 2. 맵뷰에 있는 모든 마커 삭제
                    self.naverMapView.clusterMarkers.forEach {
                        $0.mapView = nil
                    }
                    // 3. 현재 바운드에 맞는 마커 바로 맵뷰에 추가
                    self.naverMapView.configureNewMarkers(afterClusters: afterClusters, markerColor: self.animator.markerColor)
                } else { // 애니메이션중이 아닐때
                    self.naverMapView.deleteBeforeMarkers()
                    self.naverMapView.clusterObjects = afterClusters
                    self.animator.animate(before: beforeClusters, after: afterClusters, type: .move)
                }
            }
        }

        viewModel.markers.bind { afterClusters in
            DispatchQueue.main.async {
                self.naverMapView.deleteBeforeMarkers()
                self.naverMapView.clusterObjects = afterClusters
                self.animator.animate(before: [], after: afterClusters, type: .appear)
            }
        }
    }
    
    @objc func fetchDidTouched() {
        guard !fetchBtn.isAnimating else { return }
        fetchBtn.animation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6, execute: {
            self.fetchBtn.endAnimation()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let places = self.fetchPlaceInScreen()
            self.viewModel?.fetchedPlaces = places
            self.viewModel?.updatePlaces(places: places, bounds: self.naverMapView.coordBounds)
        })
    }
    
    func fetchPlaceInScreen() -> [Place] {
        return self.dataProvider.fetch(bounds: naverMapView.coordBounds)
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
        
        guard !fetchBtn.isAnimating else { return }
        fetchBtn.removeFromSuperview()
        fetchBtn = nil
        setupFetchButton()
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
        AlertManager.shared.okCancel(controller: self, title: title, message: message, okHandler: okHandler, cancelHandler: nil)
    }
    
    func naverMapView(_ mapView: NaverMapView, markerWillDeleted place: Place) {
        let title = "마커 삭제"
        let message = "마커를 삭제하시겠습니까"
        let okHandler: (UIAlertAction) -> Void = { [weak self] _ in
            guard let self = self else { return }
            self.dataProvider.delete(object: place, completionHandler: self.coreDataUpdateHandler)
        }
        AlertManager.shared.okCancel(controller: self, title: title, message: message, okHandler: okHandler, cancelHandler: nil)
    }
}
