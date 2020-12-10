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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.layer.borderWidth = 1
        backgroundColor = .systemGray5
    }
    
    }
}
