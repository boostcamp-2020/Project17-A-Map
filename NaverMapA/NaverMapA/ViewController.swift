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
        let coordBounds = mapView.projection.latlngBounds(fromViewBounds: UIScreen.main.bounds)
        let datas: [JsonPlace] = (0..<20).map { _ in
            let randomLng = Double.random(in: coordBounds.southWestLng...coordBounds.northEastLng)
            let randomLat = Double.random(in: coordBounds.southWestLat...coordBounds.northEastLat)
            let randomPlace = JsonPlace(id: "", name: "", longitude: randomLng, latitude: randomLat, imageUrl: "", category: "")
            let marker = NMFMarker(position: NMGLatLng(lat: randomLat, lng: randomLng))
            marker.mapView = mapView
            return randomPlace
        }
        DispatchQueue.main.async { [weak self] in
            self?.kMeansClustering(datas) { (centroids) in
                centroids.forEach {
                    let marker = NMFMarker(position: NMGLatLng(lat: $0.latitude, lng: $0.longitude))
                    marker.iconImage = NMF_MARKER_IMAGE_BLACK
                    marker.iconTintColor = .red
                    marker.mapView = mapView
                }
            }
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
    private func kMeansClustering(_ datas: [JsonPlace], completion: ([JsonPlace]) -> Void) {
        let K_COUNT = 5
        var centroids = [JsonPlace]()
        (0..<K_COUNT).forEach { centroids.append(datas[$0]) }
        var flag: Bool
        repeat {
            flag = false
            var temp = [[JsonPlace]](repeating: [], count: K_COUNT)
            for i in (0..<datas.count) {
                var minDistance = Double.greatestFiniteMagnitude
                var indexOfNearest = 0
                for (index, centroid) in centroids.enumerated() {
                    let distance = datas[i].distanceTo(centroid)
                    if distance < minDistance {
                        minDistance = distance
                        indexOfNearest = index
                    }
                }
                temp[indexOfNearest].append(datas[i])
            }
            var newCentroids = temp.map {
                JsonPlace.centroid(of: $0)
            }
            newCentroids.sort(by: { $0.longitude < $1.longitude })
            centroids.sort(by: { $0.longitude < $1.longitude })
            if !newCentroids.elementsEqual(centroids) {
                flag = true
                centroids = newCentroids
            }
        } while flag
        completion(centroids)
    }
}

extension ViewController {
    enum ViewControllerInputGuide: String {
        case jsonAsset = "restaurant_list"
    }
}
