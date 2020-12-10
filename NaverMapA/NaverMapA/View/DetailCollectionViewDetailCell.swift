//
//  CollectionViewDetailCell.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/01.
//

import UIKit

class DetailCollectionViewDetailCell: UICollectionViewCell {
    
    static let identifier: String = String(describing: DetailCollectionViewDetailCell.self)
    
    var representedIdentifier: UUID?
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.layer.borderWidth = 1
        backgroundColor = .systemGray5
    }

}
