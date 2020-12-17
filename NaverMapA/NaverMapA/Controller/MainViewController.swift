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
    var animator: BasicAnimator!
    let container = DependencyContainer()
    
    @IBOutlet weak var settingButton: UIButton!
    
    // MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = NMFAuthManager.shared().clientId else {
            AlertManager.shared.clientIdIsNil(controller: self)
            return
        }
        setUpMapView()
        setUpCoreData()
        setUpOtherViews()
        setupViewModel()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.bringSubviewToFront(settingButton)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let markerColor = GetMarkerColor.getColor(colorString: InfoSetting.markerColor)
        let markerWidth = NMFMarker().iconImage.imageWidth * 1.4
        let markerHeight = NMFMarker().iconImage.imageHeight * 1.4
        let info = MarkerInfo(width: markerWidth,
                              height: markerHeight,
                              color: markerColor)
        
        viewModel?.clusteringAlgorithm = container.algorithm()
        animator = container.animation(mapView: naverMapView, info: info)
        animator.delegate = self
        updateMapView()
    }
    
    // MARK: - Initailize
    
    func setupViewModel() {
        viewModel = MainViewModel(algorithm: container.algorithm())
    }
    
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
        backBarButtonItem.tintColor = .label
        self.navigationItem.backBarButtonItem = backBarButtonItem
        setupFetchButton()
    }
    
    func setupFetchButton() {
        let fetchWidth: CGFloat = 140
        let fetchHeight: CGFloat = 40
        fetchBtn = FetchButton(frame: CGRect(x: 0, y: 0, width: fetchWidth, height: fetchHeight))
        view.addSubview(fetchBtn)
        fetchBtn.addTarget(self, action: #selector(fetchDidTouched), for: .touchDown)
        fetchBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fetchBtn.widthAnchor.constraint(equalToConstant: fetchWidth),
            fetchBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fetchBtn.heightAnchor.constraint(equalToConstant: fetchHeight),
            fetchBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
    
    // MARK: - Methods
    
    private func coreDataDeleteHandler(result: Error?) {
        if result == nil {
            updateMapView()
        }
    }
    
    private func coreDataInsertHandler(result: Place?) {
        if let place = result {
            self.viewModel?.fetchedPlaces.append(place)
            updateMapView()
        }
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.animationMarkers.bind { (beforeClusters, afterClusters) in
            DispatchQueue.main.async {
                if self.animator.isAnimating { // 애니메이션중일때
                    // 1. 애니메이션중인 레이어 모두 지우기
                    self.animator.isAnimating = false // 새로운 마커를 그리지 않음
                    self.animationLayer.sublayers?.forEach {
                        $0.removeFromSuperlayer()
                    }
                    // 2. 맵뷰에 있는 모든 마커 삭제
                    self.naverMapView.clusterMarkers.forEach {
                        $0.mapView = nil
                    }
                    // 3. 현재 바운드에 맞는 마커 바로 맵뷰에 추가
                    self.naverMapView.clusterObjects = afterClusters
                    self.naverMapView.configureNewMarkers(afterClusters: afterClusters, markerColor: self.animator.markerInfo.color)
                } else { // 애니메이션중이 아닐때
                    self.naverMapView.deleteBeforeMarkers()
                    self.naverMapView.clusterObjects = afterClusters
                    var findLeaf = false
                    for cluster in afterClusters {
                        if cluster.latitude == self.naverMapView.selectedLeafMarker?.position.lat && cluster.longitude == self.naverMapView.selectedLeafMarker?.position.lng {
                            findLeaf = true
                            break
                        }
                    }
                    if !findLeaf {
                        self.naverMapView.selectedLeafMarker = nil
                    }
                    self.animator.animate(before: beforeClusters, after: afterClusters, type: .move)
                }
            }
        }
        
        viewModel.markers.bind { afterClusters in
            DispatchQueue.main.async {
                self.naverMapView.deleteBeforeMarkers()
                self.naverMapView.clusterObjects = afterClusters
                self.animator.animate(before: [], after: afterClusters, type: .appear)
                var findLeaf = false
                for cluster in afterClusters {
                    if cluster.latitude == self.naverMapView.selectedLeafMarker?.position.lat && cluster.longitude == self.naverMapView.selectedLeafMarker?.position.lng {
                        findLeaf = true
                        break
                    }
                }
                if !findLeaf {
                    self.naverMapView.selectedLeafMarker = nil
                }
            }
        }
    }
    
    @objc func fetchDidTouched() {
        guard !fetchBtn.isAnimating else { return }
        fetchBtn.animation()
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let places = self.dataProvider.fetch(bounds: self.naverMapView.coordBounds)
            self.viewModel?.fetchedPlaces = places
            self.viewModel?.updatePlaces(places: places, bounds: self.naverMapView.coordBounds) {
                DispatchQueue.main.async {
                    if self.naverMapView.selectedLeafMarker == nil {
                        return
                    }
                    var findLeaf = false
                    for marker in self.naverMapView.clusterMarkers {
                        if marker.position.lat == self.naverMapView.selectedLeafMarker?.position.lat && marker.position.lng == self.naverMapView.selectedLeafMarker?.position.lng {
                            self.naverMapView.selectedLeafMarker = marker
                            findLeaf = true
                            break
                        }
                    }
                    if !findLeaf {
                        self.naverMapView.selectedLeafMarker = nil
                    }
                }
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6, execute: {
            self.fetchBtn.endAnimation()
        })
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
            self.dataProvider.insertPlace(latitide: latlng.lat, longitude: latlng.lng, completionHandler: self.coreDataInsertHandler)
        }
        AlertManager.shared.okCancel(controller: self, title: title, message: message, okHandler: okHandler, cancelHandler: nil)
    }
    
    func naverMapView(_ mapView: NaverMapView, markerWillDeleted place: Place) {
        let title = "마커 삭제"
        let message = "마커를 삭제하시겠습니까"
        let okHandler: (UIAlertAction) -> Void = { [weak self] _ in
            guard let self = self else { return }
            self.dataProvider.delete(object: place, completionHandler: self.coreDataDeleteHandler)
        }
        AlertManager.shared.okCancel(controller: self, title: title, message: message, okHandler: okHandler, cancelHandler: nil)
    }
}

extension MainViewController: AnimatorDelegate {
    func animator(_ animator: AnimatorManagable, didAppeared cluster: Cluster, color: UIColor) {
        self.naverMapView.configureNewMarker(afterCluster: cluster, markerColor: color)
    }
    
    func animator(_ animator: AnimatorManagable, didMoved clusters: [Cluster], color: UIColor) {
        self.naverMapView.configureNewMarkers(afterClusters: clusters, markerColor: color)
    }
}
