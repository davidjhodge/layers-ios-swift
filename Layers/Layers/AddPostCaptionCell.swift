//
//  AddPostCaptionCell.swift
//  Layers
//
//  Created by David Hodge on 10/17/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class AddPostCaptionCell: UICollectionViewCell {
    
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .white
    }
}
