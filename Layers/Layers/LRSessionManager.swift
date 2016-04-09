//
//  LRSessionManager.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

class LRSessionManager
{
    // MARK: Public Variables
    static let sharedManager: LRSessionManager = LRSessionManager()
    
    var currentUser: User?
    
    // MARK: Initialization
    init ()
    {
        //Log debugging
        
        //initialize alamofire network manager
        
        //restore credentials
        restoreCredentials()
    }
    
    //MARK: Local Account Access
    private func restoreCredentials()
    {
        
    }
}