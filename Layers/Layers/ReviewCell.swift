//
//  ReviewCell.swift
//  Layers
//
//  Created by David Hodge on 4/12/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class ReviewCell: UITableViewCell
{
    @IBOutlet weak var starView: CosmosView!
    
    @IBOutlet weak var reviewTitleLabel: UILabel!
    
    @IBOutlet weak var reviewContentLabel: UILabel!
    
    @IBOutlet weak var sourceDomainLabel: UILabel!
}
