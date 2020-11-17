//
//  ViewController.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/17.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let _ = NMFAuthManager.shared().clientId else {
            let alert = UIAlertController(title: "에러", message: "clientId 실종", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }
            alert.addAction(okAction)
            present(alert, animated: false, completion: nil)
            return
        }
    }

}
