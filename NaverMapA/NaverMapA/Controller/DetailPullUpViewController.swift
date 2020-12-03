//
//  DetailPullUpViewController.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/11/30.
//

import UIKit

protocol PullUpViewDelegate: class {
    func dismissPullUpVC()
}

class DetailPullUpViewController: UIViewController {
    
    static let identifier: String = String(describing: DetailPullUpViewController.self)

    private enum State {
        case full
        case half
        case short
    }

    // MARK: - Properties
    
    private var fullViewPosition: CGFloat {
        return UIScreen.main.bounds.height - self.view.frame.height
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
    
    // MARK: - Views
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVC()
        setUpShortLine()
        setUpGesture()
        setUpCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            self.moveView(state: .short)
        })
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
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    private func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.register(UINib(nibName: DetailCollectionViewListCell.identifier, bundle: .main), forCellWithReuseIdentifier: DetailCollectionViewListCell.identifier)
        collectionView.register(UINib(nibName: DetailCollectionViewDetailCell.identifier, bundle: .main), forCellWithReuseIdentifier: DetailCollectionViewDetailCell.identifier)
        collectionView.layoutIfNeeded()
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let insets = (collectionView.contentInset.left + collectionView.contentInset.right)
        layout?.estimatedItemSize = CGSize(width: collectionView.bounds.width - insets, height: 100)
    }
    
    // MARK: - Methods
    
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
        dataSource.setUpViewModels(cluster: cluster, completion: {
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
        })
    }
    
    // MARK: PanGesture
    
    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        moveView(panGestureRecognizer: recognizer)
        guard recognizer.state == .ended else { return }
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            let maxY = UIScreen.main.bounds.height
            let yPosition = self.view.frame.minY
            if yPosition <= maxY / 3.0 {
                self.moveView(state: .full)
            } else if yPosition <= maxY / 3.0 * 2.0 {
                self.moveView(state: .half)
            } else {
                self.moveView(state: .short)
            }
        })
    }

    // MARK: IBActions
    
    @IBAction private func touchedCloseButton(_ sender: Any) {
        delegate?.dismissPullUpVC()
    }
    
}

// MARK: CollectionViewDelegate
extension DetailPullUpViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset.y = 0
            scrollView.isScrollEnabled = false
        }
    }
    
}
