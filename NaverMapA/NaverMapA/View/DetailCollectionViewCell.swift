//
//  DetailCollectionViewCell.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/12/11.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    var nameLabel: UILabel?
    var addressLabel: UILabel?
    var imageView: UIImageView?
    
    var representedIdentifier: UUID?
    weak var addressTask: URLSessionTask?
    weak var imageTask: URLSessionTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.layer.borderWidth = 1
        backgroundColor = .systemGray5
        nameLabel = self.viewWithTag(1) as? UILabel
        addressLabel = self.viewWithTag(2) as? UILabel
        imageView = self.viewWithTag(3) as? UIImageView
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel?.text = "불러오는 중"
        addressLabel?.text = "불러오는 중"
        imageView?.image = CacheData.publicCache.placeholderImage
        addressTask?.cancel()
        imageTask?.cancel()
    }
    func configure(viewModel: DetailViewModel?) {
        guard let viewModel = viewModel else {
            self.nameLabel?.text = "viewModel이 없습니다."
            self.addressLabel?.text = "viewModel이 없습니다."
            self.imageView?.image = CacheData.publicCache.placeholderImage
            return
        }
        self.nameLabel?.text = viewModel.name.value
        addressTask = CacheData.publicCache.getAddress(lng: viewModel.longitude.value, lat: viewModel.latitude.value) { [weak self] address in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.addressLabel?.text = (address as String?) ?? "도로명 주소가 없습니다."
            }
            guard let url = viewModel.url.value else {
                DispatchQueue.main.async {
                    self.imageView?.image = UIImage(systemName: "xmark.circle")!
                }
                return
            }
            self.imageTask = CacheData.publicCache.getImage(url: url) { image in
                guard let image = image else {
                    DispatchQueue.main.async {
                        self.imageView?.image = UIImage(systemName: "xmark.circle")!
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.imageView?.image = image
                }
            }
        }
    }
}
