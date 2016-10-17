//
//  ImageCell.swift
//  Layers
//
//  Created by David Hodge on 10/16/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 4.0
        
        backgroundColor = .white

    }
}
