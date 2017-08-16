//
//  AWSManager.swift
//  Layers
//
//  Created by David Hodge on 5/30/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

import AWSCognitoIdentityProvider
import AWSCore
import AWSCognito
import AWSSNS

import FBSDKLoginKit
import KeychainAccess

import SwiftyJSON

class AWSManager: NSObject
{
    // Static variable to allow single access to the service.
    static let defaultManager = AWSManager()
    
    // Access the Keychain
    private let keychain: Keychain = Keychain(service: NSBundle.mainBundle().bundleIdentifier!)
    
    override init()
    {
        super.init()
        
        AWSLogger.defaultLogger().logLevel = .Error
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: kAWSCognitoIdentityPoolId)
        let defaultServiceConfiguration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
    }
    
    // MARK: SNS
    func registerWithSNS(deviceToken: NSData?, completionHandler: LRCompletionBlock?)
    {
        if let tokenData = deviceToken
        {
            let platformEndpointRequest = AWSSNSCreatePlatformEndpointInput()
            platformEndpointRequest.token = deviceTokenAsString(tokenData)
            platformEndpointRequest.platformApplicationArn = kAWSSNSApplicationARN
            
            // Pass user identity id and timezone
            let userData: Dictionary<String, AnyObject> = ["timezone_offset": NSTimeZone.localTimeZone().secondsFromGMT]
            
            let jsonUserData = JSON(userData).rawString(NSUTF8StringEncoding, options: .PrettyPrinted)
            
            platformEndpointRequest.customUserData = jsonUserData
            
            // Create platform endpoint
            let snsManager = AWSSNS.defaultSNS()
            
            snsManager.createPlatformEndpoint(platformEndpointRequest).continueWithBlock({ (task) -> AnyObject! in
                
                if task.error != nil
                {
                    if let completion = completionHandler
                    {
                        if let errorMessage = task.error?.formattedMessage()
                        {
                            completion(success: false, error: errorMessage, response: nil)
                        }
                    }
                    
                    log.error(task.error?.localizedDescription)
                }
                else
                {
                    // Success
                    
                    // Sync Endpoint with Cognito Sync
                    if let endpointResponse = task.result as? AWSSNSCreateEndpointResponse
                    {
                        if let endpointARN: String = endpointResponse.endpointArn
                        {
                            if let completion = completionHandler
                            {
                                completion(success: true, error: nil, response: endpointARN)
                            }
                            return nil
                        }
                        else
                        {
                            if let completion = completionHandler
                            {
                                completion(success: false, error: "Device Token could not be saved to Cognito.", response: nil)
                            }
                        }
                    }
                    else
                    {
                        if let completion = completionHandler
                        {
                            completion(success: false, error: "Invalid Endpoint Response.", response: nil)
                        }
                    }
                }
                
                return AWSTask(result: task.result)
            })
        }
    }
    
    func deviceTokenAsString(tokenData: NSData) -> String
    {
        let rawDeviceString: String = "\(tokenData)"
        
        let noSpaces = rawDeviceString.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        let temp: String = noSpaces.stringByReplacingOccurrencesOfString("<", withString: "")
        
        return temp.stringByReplacingOccurrencesOfString(">", withString: "")
    }
}
