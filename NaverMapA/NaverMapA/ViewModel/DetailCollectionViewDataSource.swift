//
//  DetailCollectionViewDataSource.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/01.
//

import UIKit

final class DetailCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    // MARK: Properties
    
    private var viewModels: [DetailViewModel] = []
    private let imageCacher = CacheData()
    
    // MARK: UICollectionViewDataSource
    
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
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailPullUpViewController.detailCollectionViewDetailCell, for: indexPath) as? DetailCollectionViewCell {
            cell.configure(viewModel: viewModel)
            return cell
        } else if
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailPullUpViewController.detailCollectionViewListCell, for: indexPath) as? DetailCollectionViewCell {
            cell.configure(viewModel: viewModel)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}
