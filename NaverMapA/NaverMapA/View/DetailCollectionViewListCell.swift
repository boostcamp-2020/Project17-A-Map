//
//  CollectionViewListCell.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/01.
//

import UIKit

class DetailCollectionViewListCell: UICollectionViewCell {
    
    static let identifier: String = String(describing: DetailCollectionViewListCell.self)
    
    var representedIdentifier: UUID?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    private weak var addressTask: URLSessionTask?
    private weak var imageTask: URLSessionTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.layer.borderWidth = 1
        backgroundColor = .systemGray5
    }
    
    override func prepareForReuse() {
        nameLabel.text = "불러오는 중"
        addressLabel.text = "불러오는 중"
        imageView.image = CacheData.publicCache.placeholderImage
        addressTask?.cancel()
        imageTask?.cancel()
    }
    
    func configure(viewModel: DetailViewModel?) {
        guard let viewModel = viewModel else {
            self.nameLabel.text = "viewModel이 없습니다."
            self.addressLabel.text = "viewModel이 없습니다."
            self.imageView.image = CacheData.publicCache.placeholderImage
            return
        }
        self.nameLabel.text = viewModel.name.value
        
        addressTask = CacheData.publicCache.getAddress(lng: viewModel.longitude.value, lat: viewModel.latitude.value) { [weak self] address in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.addressLabel.text = (address as String?) ?? "도로명 주소가 없습니다."
            }
            guard let url = viewModel.item.value.url else {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(systemName: "xmark.circle")!
                }
                return
            }
            self.imageTask = CacheData.publicCache.getImage(url: url) { image in
                guard let image = image else {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(systemName: "xmark.circle")!
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
}
