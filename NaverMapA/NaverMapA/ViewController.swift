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
    // MARK: - Properties
    private var places: [Place] = []
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
        DispatchQueue.main.async { [weak self] in
            self?.loadJson()
            self?.places = CoreDataManager.shared.fetch(request: Place.fetchRequest())
            self?.places.forEach({
                print($0.name)
                let marker = NMFMarker(position: NMGLatLng(lat: $0.latitude, lng: $0.longitude))
                marker.mapView = mapView
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
    private func loadJson() {
        guard let count = CoreDataManager.shared.count(request: Place.fetchRequest()),
              count == 0 else { return }
        guard let data = NSDataAsset(name: ViewControllerInputGuide.jsonAsset.rawValue)?.data else {
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

extension ViewController {
    enum ViewControllerInputGuide: String {
        case jsonAsset = "restaurant_list"
    }
}
