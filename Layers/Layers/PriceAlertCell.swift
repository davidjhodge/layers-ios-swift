//
//  PriceAlertCell.swift
//  Layers
//
//  Created by David Hodge on 5/2/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class PriceAlertCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var productLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
