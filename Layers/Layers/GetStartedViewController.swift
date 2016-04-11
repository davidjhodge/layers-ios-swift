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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func getStarted(sender: AnyObject)
    {
        AppStateTransitioner.transitionToMainStoryboard(true)
    }
    
    @IBAction func alreadyHasAccount(sender: AnyObject)
    {
        performSegueWithIdentifier("ShowLoginViewController", sender: self)
    }
}
