//
//  DetailCollectionViewDataSource.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/01.
//

import UIKit

final class DetailCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    // MARK: Properties
    
    private var viewModels: [DetailViewModel] = []
    private let asyncFetcher = AsyncFetcher()
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
        //        viewModel.loadAddress {
        //            DispatchQueue.main.async {
        //                guard collectionView.numberOfItems(inSection: indexPath.section) > indexPath.item else { return }
        //            }
        //        }
        //        viewModel.loadImage(imageCacher: imageCacher) {
        //            DispatchQueue.main.async {
        //                guard collectionView.numberOfItems(inSection: indexPath.section) > indexPath.item else { return }
        //                collectionView.reloadItems(at: [indexPath])
        //            }
        //        }
        //
//        let identifier = viewModel.identifier
        if placeCount == 1,
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewDetailCell.identifier, for: indexPath) as? DetailCollectionViewDetailCell {
            cell.configure(viewModel: viewModel)
//            cell.representedIdentifier = identifier
//            if let fetchedData = asyncFetcher.fetchedData(for: viewModel.identifier) {
//                bindDetailCell(cell: cell, viewModel: fetchedData)
//            } else {
//                bindDetailCell(cell: cell, viewModel: nil)
//                self.asyncFetcher.fetchAsync(viewModel) { [weak self] fetchedData in
//                    DispatchQueue.main.async {
//                        guard cell.representedIdentifier == identifier else { return }
//                        self?.bindDetailCell(cell: cell, viewModel: fetchedData)
//                        collectionView.reloadItems(at: [indexPath])
//                    }
//                }
//            }
            return cell
        } else if
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewListCell.identifier, for: indexPath) as? DetailCollectionViewListCell {
            cell.configure(viewModel: viewModel)
//            cell.representedIdentifier = identifier
//            if let fetchedData = asyncFetcher.fetchedData(for: viewModel.identifier) {
//                bindListCell(cell: cell, viewModel: fetchedData)
//            } else {
//                bindListCell(cell: cell, viewModel: nil)
//                self.asyncFetcher.fetchAsync(viewModel) { [weak self] fetchedData in
//                    DispatchQueue.main.async {
//                        guard cell.representedIdentifier == identifier else { return }
//                        self?.bindListCell(cell: cell, viewModel: fetchedData)
//                        collectionView.reloadItems(at: [indexPath])
//                    }
//                }
//            }
            return cell
        } else {
            return UICollectionViewCell()
        }
        
    }
    
    // MARK: UICollectionViewDataSourcePrefetching
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let viewModel = viewModels[indexPath.item]
            asyncFetcher.fetchAsync(viewModel)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths where indexPath.item < viewModels.count {
            let viewModel = viewModels[indexPath.item]
            asyncFetcher.cancelFetch(viewModel)
        }
    }
    
    // MARK: ViewModel Bind Methods
    
    private func bindDetailCell(cell: DetailCollectionViewDetailCell, viewModel: DetailViewModel?) {
        guard let viewModel = viewModel else {
            cell.addressLabel.text = "불러오는 중"
            cell.imageView.image = imageCacher.placeholderImage
            return
        }
        viewModel.address.bindAndFire { address in
            DispatchQueue.main.async {
                cell.addressLabel.text = "\(address)"
            }
        }
        viewModel.item.bindAndFire { item in
            DispatchQueue.main.async {
                cell.imageView.image = item.image
            }
        }
    }
    
    private func bindListCell(cell: DetailCollectionViewListCell, viewModel: DetailViewModel?) {
        guard let viewModel = viewModel else {
            cell.nameLabel.text = "불러오는 중"
            cell.addressLabel.text = "불러오는 중"
            cell.imageView.image = imageCacher.placeholderImage
            return
        }
        viewModel.name.bindAndFire { name in
            DispatchQueue.main.async {
                cell.nameLabel.text = name
            }
        }
        viewModel.address.bindAndFire { address in
            DispatchQueue.main.async {
                cell.addressLabel.text = "\(address)"
            }
        }
        viewModel.item.bindAndFire { item in
            DispatchQueue.main.async {
                cell.imageView.image = item.image
            }
        }
    }
    
}
