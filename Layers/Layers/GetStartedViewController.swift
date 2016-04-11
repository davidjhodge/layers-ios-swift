//
//  GetStartedViewController.swift
//  Layers
//
//  Created by David Hodge on 4/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

class GetStartedViewController: UIViewController
{
    
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var heroImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoLabel.font = Font.CharterBold(size: 30.0)
        view.sendSubviewToBack(heroImage)
    }
    
    @IBAction func getStarted(sender: AnyObject)
    {
        AppStateTransitioner.transitionToMainStoryboard(true)
    }
    
    @IBAction func alreadyHasAccount(sender: AnyObject)
    {
        print("Already Has Account tapped")
    }
}
