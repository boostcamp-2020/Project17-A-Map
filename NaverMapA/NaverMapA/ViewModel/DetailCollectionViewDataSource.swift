//
//  DetailCollectionViewDataSource.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/01.
//

import UIKit

final class DetailCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    private var viewModels: [DetailViewModel] = []

    func setUpViewModels(cluster: Cluster, completion: @escaping () -> Void) {
        viewModels = cluster.places.map { DetailViewModel(place: $0) }
        completion()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let placeCount = viewModels.count
        guard placeCount > indexPath.item && placeCount > 0 else {
            return UICollectionViewCell()
        }
        let viewModel = viewModels[indexPath.item]
        if placeCount == 1,
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewDetailCell.identifier, for: indexPath) as? DetailCollectionViewDetailCell {
            bindDetailCell(cell: cell, viewModel: viewModel)
            cell.layoutIfNeeded()
            return cell
        } else if
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewListCell.identifier, for: indexPath) as? DetailCollectionViewListCell {
            bindListCell(cell: cell, viewModel: viewModel)
            cell.layoutIfNeeded()
            return cell
        } else {
            return UICollectionViewCell()
        }
    }

    private func bindDetailCell(cell: DetailCollectionViewDetailCell, viewModel: DetailViewModel) {
        viewModel.latitude.bindAndFire { latitude in
            cell.latitudeLabel.text = "lat: \(latitude)"
        }
        viewModel.longitude.bindAndFire { longitude in
            cell.longitudeLabel.text = "lng: \(longitude)"
        }
        viewModel.imageUrl.bindAndFire { str in
            if let url = URL(string: str),
               let data = try? Data(contentsOf: url) {
                cell.imageView.image = UIImage(data: data)
            }
        }
    }
    
    private func bindListCell(cell: DetailCollectionViewListCell, viewModel: DetailViewModel) {
        viewModel.name.bindAndFire { name in
            cell.nameLabel.text = name
        }
        viewModel.latitude.bindAndFire { latitude in
            cell.latitudeLabel.text = "lat: \(latitude)"
        }
        viewModel.longitude.bindAndFire { longitude in
            cell.longitudeLabel.text = "lng: \(longitude)"
        }
        viewModel.imageUrl.bindAndFire { str in
            if let url = URL(string: str),
               let data = try? Data(contentsOf: url) {
                cell.imageView.image = UIImage(data: data)
            }
        }
    }

}
