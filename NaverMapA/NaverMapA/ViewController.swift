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

    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
        DispatchQueue.main.async { [weak self] in
            self?.loadJson()
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
    private func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style, action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(action)
        present(alert, animated: false, completion: nil)
    }
    func loadJson() {
        guard let count = CoreDataManager.shared.count(request: Place.fetchRequest()),
              count == 0 else { return }

        guard let data = NSDataAsset(name: "restaurant_list")?.data else {
            fatalError("Missing data asset: restaurant_list")
        }
        do {
            let json = try JSONDecoder().decode([JsonPlace].self, from: data)
            json.forEach({
                CoreDataManager.shared.insertPlace(place: $0)
            })
        } catch {
            print(error)
        }
    }
}
