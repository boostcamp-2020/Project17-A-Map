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
        let identifier = viewModel.identifier
        if placeCount == 1,
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewDetailCell.identifier, for: indexPath) as? DetailCollectionViewDetailCell {
            cell.representedIdentifier = identifier
            if let fetchedData = asyncFetcher.fetchedData(for: viewModel) {
                bindDetailCell(cell: cell, viewModel: fetchedData)
            } else {
                bindDetailCell(cell: cell, viewModel: nil)
                asyncFetcher.fetchAsync(viewModel) { [weak self] fetchedData in
                    DispatchQueue.main.async {
                        guard cell.representedIdentifier == identifier else { return }
                        self?.bindDetailCell(cell: cell, viewModel: fetchedData)
                    }
                }
            }
            cell.layoutIfNeeded()
            return cell
        } else if
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewListCell.identifier, for: indexPath) as? DetailCollectionViewListCell {
            cell.representedIdentifier = identifier
            if let fetchedData = asyncFetcher.fetchedData(for: viewModel) {
                bindListCell(cell: cell, viewModel: fetchedData)
            } else {
                bindListCell(cell: cell, viewModel: nil)
                asyncFetcher.fetchAsync(viewModel) { [weak self] fetchedData in
                    DispatchQueue.main.async {
                        guard cell.representedIdentifier == identifier else { return }
                        self?.bindListCell(cell: cell, viewModel: fetchedData)
                    }
                }
            }
            cell.layoutIfNeeded()
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
        for indexPath in indexPaths {
            let viewModel = viewModels[indexPath.item]
            asyncFetcher.cancelFetch(viewModel)
        }
    }

    // MARK: ViewModel Bind Methods
    
    private func bindDetailCell(cell: DetailCollectionViewDetailCell, viewModel: DetailViewModel?) {
        guard let viewModel = viewModel else {
            cell.addressLabel.text = "불러오는 중"
            cell.imageView = nil
            return
        }
        viewModel.address?.bindAndFire { address in
            cell.addressLabel.text = "\(address)"
        }
        viewModel.imageUrl.bindAndFire { str in
            if let url = URL(string: str),
               let data = try? Data(contentsOf: url) {
                cell.imageView.image = UIImage(data: data)
            }
        }
    }
    
    private func bindListCell(cell: DetailCollectionViewListCell, viewModel: DetailViewModel?) {
        guard let viewModel = viewModel else {
            cell.nameLabel.text = "불러오는 중"
            cell.addressLabel.text = "불러오는 중"
            cell.imageView.image = nil
            return
        }
        viewModel.name.bindAndFire { name in
            cell.nameLabel.text = name
        }
        viewModel.address?.bindAndFire { address in
            cell.addressLabel.text = "\(address)"
        }
        viewModel.imageUrl.bindAndFire { str in
            if let url = URL(string: str),
               let data = try? Data(contentsOf: url) {
                cell.imageView.image = UIImage(data: data)
            }
        }
    }

}
