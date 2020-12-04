//
//  CollectionViewListCell.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/01.
//

import UIKit

class DetailCollectionViewListCell: UICollectionViewCell {
    
    static let identifier: String = String(describing: DetailCollectionViewListCell.self)

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.layer.borderWidth = 1
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}
