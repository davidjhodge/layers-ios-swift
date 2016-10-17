//
//  NewProduct.swift
//  Layers
//
//  Created by David Hodge on 10/17/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class NewProduct: NSObject {

    var userImage: UIImage?
    
    var productId: NSNumber?
    
    var customProductImage: UIImage?
    
    var customProductUrl: URL?
    
    static let sharedProduct = NewProduct()
    
    func reset()
    {
        userImage = nil
        
        productId = nil
        
        customProductImage = nil
        
        customProductUrl = nil
    }
}
