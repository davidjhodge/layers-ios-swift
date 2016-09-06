//
//  SearchCell.swift
//  Layers
//
//  Created by David Hodge on 9/6/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var resultImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        resultImageView.layer.cornerRadius = 4.0
        resultImageView.clipsToBounds = true
    }

}
