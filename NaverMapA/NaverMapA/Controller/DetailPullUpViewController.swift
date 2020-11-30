//
//  DetailPullUpViewController.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/11/30.
//

import UIKit

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
        UIScreen.main.bounds.height - 120
    }
    
    // MARK: - Views
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addTopShortLine()
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            guard let self = self else { return }
            self.view.frame = CGRect(x: 0, y: self.shortViewPosition, width: self.view.frame.width, height: self.view.frame.height)
        })
    }
    
    // MARK: - Initialize
    
    private func configure() {
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        view.layer.shadowColor = UIColor.label.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 5
    }
    
    private func addTopShortLine() {
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
    
    // MARK: - Methods
    
    private func moveView(state: State) {
        let yPosition = viewPosition(for: state)
        view.frame = CGRect(x: 0, y: yPosition, width: view.frame.width, height: view.frame.height)
    }
    
    private func moveView(panGestureRecognizer recognizer: UIPanGestureRecognizer) {
        let transition = recognizer.translation(in: view)
        let minY = view.frame.minY
        guard (minY + transition.y >= fullViewPosition) && (minY + transition.y <= shortViewPosition) else { return }
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
    
}
