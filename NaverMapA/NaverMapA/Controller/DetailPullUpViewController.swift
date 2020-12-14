//
//  DetailPullUpViewController.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/11/30.
//

import UIKit

protocol PullUpViewDelegate: class {
    func dismissPullUpVC()
    func move(toLat: Double, lng: Double)
}

class DetailPullUpViewController: UIViewController {
    static let detailCollectionViewListCell = "DetailCollectionViewListCell"
    static let detailCollectionViewDetailCell = "DetailCollectionViewDetailCell"
    static let identifier: String = String(describing: DetailPullUpViewController.self)
    
    private enum State {
        case full
        case half
        case short
    }
    
    private let panGestureVelocityThreshold: CGFloat = 200
    private let animationDuration = 0.4
    
    // MARK: - Properties
    
    private var fullViewPosition: CGFloat {
        return UIScreen.main.bounds.height - self.view.frame.height + bottomMargin.constant
    }
    
    private var halfViewPosition: CGFloat {
        return UIScreen.main.bounds.height / 2
    }
    
    private var shortViewPosition: CGFloat {
        UIScreen.main.bounds.height - 100
    }
    
    var cluster: Cluster? {
        didSet {
            bindDataSource()
        }
    }
    
    private lazy var dataSource = DetailCollectionViewDataSource()
    
    weak var delegate: PullUpViewDelegate?
    
    private var gesture: UIPanGestureRecognizer?
    
    // MARK: - Views
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVC()
        setUpShortLine()
        setUpGesture()
        setUpCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        shortenView()
    }
    
    // MARK: - Initialize
    
    private func setUpVC() {
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        view.layer.shadowColor = UIColor.label.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 5
    }
    
    private func setUpShortLine() {
        let lineWidth: CGFloat = 4
        let lineView = UIView()
        lineView.layer.cornerRadius = lineWidth / 2
        lineView.backgroundColor = .systemGray2
        self.view.addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
            lineView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            lineView.widthAnchor.constraint(equalToConstant: 50),
            lineView.heightAnchor.constraint(equalToConstant: lineWidth)
        ])
    }
    
    private func setUpGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        parent?.view.addGestureRecognizer(gesture)
        self.gesture = gesture
    }
    
    private func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = .systemGray6
        collectionView.register(UINib(nibName: DetailPullUpViewController.detailCollectionViewListCell, bundle: .main), forCellWithReuseIdentifier: DetailPullUpViewController.detailCollectionViewListCell)
        collectionView.register(UINib(nibName: DetailPullUpViewController.detailCollectionViewDetailCell, bundle: .main), forCellWithReuseIdentifier: DetailPullUpViewController.detailCollectionViewDetailCell)
    }
    
    // MARK: - Methods
    
    func shortenView() {
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.moveView(state: .short)
        }
    }
    
    private func moveView(state: State) {
        if state == .full {
            collectionView.isScrollEnabled = true
        } else {
            collectionView.isScrollEnabled = false
        }
        let yPosition = viewPosition(for: state)
        view.frame = CGRect(x: 0, y: yPosition, width: view.frame.width, height: view.frame.height)
    }
    
    private func moveView(panGestureRecognizer recognizer: UIPanGestureRecognizer) {
        let transition = recognizer.translation(in: view)
        let minY = view.frame.minY
        let yLocation = recognizer.location(in: view).y
        let velocity = recognizer.velocity(in: view)
        if yLocation <= -100 {
            recognizer.setTranslation(CGPoint.zero, in: view)
            return
        } else if yLocation < 0 && abs(velocity.y) > abs(velocity.x) && velocity.y > self.panGestureVelocityThreshold {
            shortenView()
            return
        }
        guard minY + transition.y <= shortViewPosition else { return }
        guard minY + transition.y >= fullViewPosition else {
            moveView(state: .full)
            return
        }
        view.frame = CGRect(x: 0, y: minY + transition.y, width: view.frame.width, height: view.frame.height)
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
    
    private func viewPosition(for state: State) -> CGFloat {
        switch state {
        case .full:
            return fullViewPosition
        case .half:
            return halfViewPosition
        case .short:
            return shortViewPosition
        }
    }
    
    private func bindDataSource() {
        guard let cluster = cluster else { return }
        let placeCount = cluster.places.count
        if placeCount == 1 {
            titleLabel.text = cluster.places[0].name
        } else if placeCount > 1 {
            titleLabel.text = "\(cluster.places.count)개의 장소"
        }
        let newDataSource = DetailCollectionViewDataSource()
        dataSource = newDataSource
        collectionView.dataSource = dataSource
        dataSource.setUpViewModels(cluster: cluster, completion: {
            self.collectionView.reloadData()
        })
    }
    
    // MARK: PanGesture
    
    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        moveView(panGestureRecognizer: recognizer)
        guard recognizer.state == .ended && recognizer.location(in: view).y >= 0 else { return }
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            let maxY = UIScreen.main.bounds.height
            let yPosition = self.view.frame.minY
            let velocity = recognizer.velocity(in: self.view)
            if abs(velocity.y) > abs(velocity.x) && abs(velocity.y) > self.panGestureVelocityThreshold {
                if velocity.y < 0 {
                    if yPosition <= self.halfViewPosition {
                        self.moveView(state: .full)
                    } else
                    if yPosition <= self.shortViewPosition {
                        self.moveView(state: .half)
                    }
                } else {
                    if yPosition >= self.halfViewPosition {
                        self.moveView(state: .short)
                    } else
                    if yPosition >= self.fullViewPosition {
                        self.moveView(state: .half)
                    }
                }
                return
            }
            if yPosition <= maxY / 3.0 {
                self.moveView(state: .full)
            } else if yPosition <= maxY / 3.0 * 2.0 {
                self.moveView(state: .half)
            } else {
                self.moveView(state: .short)
            }
        }
    }
    
    // MARK: IBActions
    
    @IBAction private func touchedCloseButton(_ sender: Any) {
        delegate?.dismissPullUpVC()
        guard let gesture = gesture else { return }
        parent?.view.removeGestureRecognizer(gesture)
    }
    
}

// MARK: CollectionViewDelegate
/**
 스크롤 이벤트, 셀 터치 이벤트 처리
 */

extension DetailPullUpViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let place = cluster?.places[indexPath.item] else { return }
        delegate?.move(toLat: place.latitude, lng: place.longitude)
        if cluster?.places.count != 1 {
            let newCluster: BasicCluster = {
                var cluster = BasicCluster()
                cluster.places.append(place)
                return cluster
            }()
            self.cluster = newCluster
        }
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            guard let self = self else { return }
            self.moveView(state: .half)
        })
    }
    
}

extension DetailPullUpViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 130)
    }
}

// MARK: GestureRecognizerDelegate
/**
 CollectionView의 스크롤 PanGesture와 PullUpVC Custom PanGesture 동시 인식 처리
 */

extension DetailPullUpViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard otherGestureRecognizer == collectionView.panGestureRecognizer && collectionView.contentOffset.y > 0 else {
            return false
        }
        return true
    }
    
}
