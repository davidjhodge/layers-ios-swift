//
//  GetStartedViewController.swift
//  Layers
//
//  Created by David Hodge on 4/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import ObjectMapper

class GetStartedViewController: UIViewController
{
    @IBOutlet weak var getStartedButton: UIButton!

    @IBOutlet weak var alreadyHasAccountButton: UIButton!
    
    @IBOutlet weak var logoLabel: UILabel!
    
    @IBOutlet weak var heroImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoLabel.attributedText = NSAttributedString(string: "LAYERS".uppercaseString, attributes: [NSFontAttributeName:Font.CharterBold(size: 30.0),
            NSKernAttributeName:3])
        
        view.sendSubviewToBack(heroImage)
        
        getStartedButton.addTarget(self, action: #selector(startBrowsing), forControlEvents: .TouchUpInside)

        alreadyHasAccountButton.addTarget(self, action: #selector(login), forControlEvents: .TouchUpInside)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        enableButtons()
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        navigationController?.setNavigationBarHidden(false, animated: false)
//    }

    // MARK: Actions
    
    func startBrowsing()
    {
        disableButttons()
        
        AppStateTransitioner.transitionToMainStoryboard(true)
    }
    
    func login()
    {
        disableButttons()
        
        performSegueWithIdentifier("ShowEmailLoginViewController", sender: self)
    }
    
    // MARK: Handle UI Interactivity
    func disableButttons()
    {
        getStartedButton.userInteractionEnabled = false
        alreadyHasAccountButton.userInteractionEnabled = false
    }
    
    func enableButtons()
    {
        getStartedButton.userInteractionEnabled = true
        alreadyHasAccountButton.userInteractionEnabled = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowOnboardingContainerViewController"
        {
            navigationController?.setNavigationBarHidden(true, animated: false)
            
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
            
            //Add Child Vie Controller
        }
        else if segue.identifier == "ShowEmailLoginViewController"
        {
            navigationController?.setNavigationBarHidden(false, animated: false)

        }
    }
}
