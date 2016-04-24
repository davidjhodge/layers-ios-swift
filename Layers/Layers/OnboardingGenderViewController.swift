//
//  OnboardingGenderViewController.swift
//  Layers
//
//  Created by David Hodge on 4/23/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class OnboardingGenderViewController: UIViewController
{
    @IBOutlet weak var menButton: UIButton!
    
    @IBOutlet weak var womenButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menButton.setTitle("Men".uppercaseString, forState: .Normal)
        womenButton.setTitle("Women".uppercaseString, forState: .Normal)

        menButton.addTarget(self, action: #selector(menSelected), forControlEvents: .TouchUpInside)
        
        womenButton.addTarget(self, action: #selector(womenSelected), forControlEvents: .TouchUpInside)
    }
    
    // MARK: Actions
    func menSelected()
    {
        LRSessionManager.sharedManager.currentUser?.gender = "male"
        
        performSegueWithIdentifier("ShowOnboardingBrandsViewController", sender: self)
    }
    
    func womenSelected()
    {
        LRSessionManager.sharedManager.currentUser?.gender = "female"
        
        performSegueWithIdentifier("ShowOnboardingBrandsViewController", sender: self)
    }
}