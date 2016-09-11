//
//  ProductListCell.swift
//  Layers
//
//  Created by David Hodge on 9/10/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class ProductListCell: UICollectionViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        productImageView.layer.cornerRadius = productImageView.bounds.size.width * 0.5
        productImageView.clipsToBounds = true
    }
}
