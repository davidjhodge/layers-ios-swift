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
        
        title = "Email"

        logoLabel.font = Font.CharterBold(size: 30.0)
        view.sendSubviewToBack(heroImage)
        
        getStartedButton.addTarget(self, action: #selector(startOnboarding), forControlEvents: .TouchUpInside)

        alreadyHasAccountButton.addTarget(self, action: #selector(login), forControlEvents: .TouchUpInside)
        
//        LRSessionManager.sharedManager.registerAuthorized("david@trylayers.com", password: "password123")
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
    
    func startOnboarding()
    {
        disableButttons()
        
        performSegueWithIdentifier("ShowOnboardingContainerViewController", sender: self)
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
