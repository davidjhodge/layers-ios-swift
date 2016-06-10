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

import SwiftyJSON

private let kAWSCognitoAppClientId = "7i6ivdpa5oh5mvgo097i3ca17u"
private let kAWSCognitoAppClientSecret = "1oi7a878pig00vb0jl25s47gc7uq8g70ca8o36ndrg9ued8tk04e"
private let kAWSCognitoIdentityPoolId = "us-east-1:cf0934de-5e7b-4aef-b1d4-e0f4a849cc55"
private let kAWSCognitoUserPoolId = "us-east-1_jEKsn6S9s"
private let kAWSCognitoUserPoolKey = "kUserPool"

class AWSManager: NSObject, AWSIdentityProviderManager
{
    // Static variable to allow single access to the service.
    static let defaultManager = AWSManager()
    
    var credentialsProvider: AWSCognitoCredentialsProvider!
    
    var userPool: AWSCognitoIdentityUserPool!

    var socialLoginDict: Dictionary<String,String>?

    override init()
    {
        super.init()
        
        AWSLogger.defaultLogger().logLevel = .Verbose

        self.setConfiguration()
                
        // Respond if the identity changes when authentication state changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(identityDidChange), name: AWSCognitoIdentityIdChangedNotification, object: nil)

    }
    
    func setConfiguration()
    {
        // Configures AWS Cognito
        credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: kAWSCognitoIdentityPoolId, identityProviderManager: self)
        let defaultServiceConfiguration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        
        fetchAccessToken({ (success, error, response) -> Void in
         
            if success
            {
                // If we have received valid credentials, we can configure the user pool
                self.configureUserPool()
            }
        })
    }
    
    func fetchAccessToken(completionHandler: LRCompletionBlock?)
    {
        // Fetch temporary Credentials from Aamzon
        credentialsProvider.credentials().continueWithBlock({ (task: AWSTask) -> AnyObject! in
          
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
                if let completion = completionHandler
                {
                    if let result = task.result as? AWSCredentials
                    {
                        let accessToken = result.accessKey
                        
                        completion(success: true, error: nil, response: accessToken)
                    }
                    else
                    {
                        completion(success: false, error: "INVALID_AWS_TASK_RESPONSE".localized, response: nil)

                    }
                }
            }
            
            return nil
        })
    }
    
    func configureUserPool()
    {
        // AWS User Pools
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: kAWSCognitoAppClientId, clientSecret: kAWSCognitoAppClientSecret, poolId: kAWSCognitoUserPoolId)
        AWSCognitoIdentityUserPool.registerCognitoIdentityUserPoolWithUserPoolConfiguration(userPoolConfiguration, forKey:kAWSCognitoUserPoolKey)
        userPool = AWSCognitoIdentityUserPool(forKey: kAWSCognitoUserPoolKey)
    }
    
    // MARK: AWSIdentityProviderManager Protocol
    func logins() -> AWSTask
    {
        if credentialsProvider != nil
        {
            if let socialLogins = socialLoginDict
            {
                return AWSTask(result: socialLogins)
            }
        }
        
        return AWSTask(result: nil)
    }
    
    // MARK: Credential Management
    func isAuthorized() -> Bool
    {        
        if userPool.currentUser() != nil
        {
            return true
        }
        
        return false
    }
    
    func fetchIdentityId(completionHandler: LRCompletionBlock?)
    {
        // Retrieves cognito identity locally if one is cached, and from the AWS Cognito Remote service if none exists
        credentialsProvider.getIdentityId().continueWithBlock({ (task) -> AnyObject! in
            
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
                // Success!
                if let identityId = task.result as? String
                {
                    if let completion = completionHandler
                    {
                        completion(success: true, error: task.error?.localizedDescription, response: identityId)
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: false, error: "INVALID_AWS_TASK_RESPONSE".localized, response: nil)
                    }
                }
            }
            
            return nil
            
        })
    }
    
    // MARK: SNS
    func registerWithSNS(deviceToken: NSData?, completionHandler: LRCompletionBlock?)
    {
        if let identityId = credentialsProvider.identityId, deviceToken = deviceToken
        {
            let kAWSSNSApplicationARN = "arn:aws:sns:us-east-1:520777401565:app/APNS_SANDBOX/Layers"
            
            let platformEndpointRequest = AWSSNSCreatePlatformEndpointInput()
            platformEndpointRequest.token = deviceTokenAsString(deviceToken)
            platformEndpointRequest.platformApplicationArn = kAWSSNSApplicationARN
            
            // Pass user identity id and timezone
            let userData: Dictionary<String, AnyObject> = ["identity_id": identityId,
                                                           "timezone_offset": NSTimeZone.localTimeZone().secondsFromGMT]
            
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
                    log.debug("SNS Platform Endpoint successfully created.")
                    
                    if let completion = completionHandler
                    {
                        completion(success: false, error: task.error?.localizedDescription, response: task.result)
                    }
                }
                
                return nil
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
    
    // MARK: User Pools
    func registerToUserPool(email: String, password: String, completionHandler: LRCompletionBlock?)
    {
        if email.characters.count > 0 && password.characters.count > 0
        {
            // Email Attribute required by AWS User Pool
            let requiredEmailAttribute = AWSCognitoIdentityUserAttributeType()
            requiredEmailAttribute.name = "email"
            requiredEmailAttribute.value = email
            
            userPool.signUp(email, password: password, userAttributes: [requiredEmailAttribute], validationData: nil).continueWithBlock( { (task: AWSTask) -> AnyObject! in
                
                if task.cancelled
                {
                    // Task Cancelled
                    if let completion = completionHandler
                    {
                        completion(success: false, error: "User Pool sign up task cancelled", response: nil)
                    }
                    
                    log.debug("Sign up task cancelled.")
                }
                else if task.error != nil
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
                    if let user: AWSCognitoIdentityUser = task.result as? AWSCognitoIdentityUser
                    {
                        if let username = user.username
                        {
                            log.debug("\(username) added to the User Pool.")
                        }
                        
                        if let username = user.username
                        {
                            log.debug("\(username) added to the User Pool.")
                        }
                    }
                }
                
                return nil
            })
        }
    }
    
    func signInToUserPool(email: String, password: String, completionHandler: LRCompletionBlock?)
    {
        if email.characters.count > 0 && password.characters.count > 0
        {
            let user = userPool.getUser()
            
            user.getSession(email, password: password, validationData: nil, scopes: nil).continueWithBlock({ (task: AWSTask) -> AnyObject! in
                
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
                    if let completion = completionHandler
                    {
                        if let session = task.result as? AWSCognitoIdentityUserSession
                        {
                            if let token = session.idToken?.tokenString
                            {
                                self.syncLoginCredentials(["cognito-idp.us-east-1.amazonaws.com/\(kAWSCognitoUserPoolId)":token])
                                
                                completion(success: true, error: nil, response: token)
                            }
                            else
                            {
                                completion(success: false, error: "INVALID_AWS_TASK_RESPONSE".localized, response: nil)
                            }
                        }
                        else
                        {
                            completion(success: false, error: "INVALID_AWS_TASK_RESPONSE".localized, response: nil)
                        }
                    }
                }
                
                return nil
            })
        }
    }
    
    func syncLoginCredentials(logins: [String: String]?)
    {
        socialLoginDict = logins
        
        credentialsProvider.identityProvider.logins().continueWithBlock( { (task: AWSTask!) -> AnyObject! in
            
            if task.error != nil
            {
                log.error(task.error?.localizedDescription)
            }
            else
            {
                log.debug("Social Login successfully added.")
            }
            
            return nil
        })
    }
    
    func clearAWSCache()
    {
        // Clear AWS Datasets
        AWSCognito.defaultCognito().wipe()
        
        // Clear AWS Cognito Temporary Credentials
        credentialsProvider.clearCredentials()
    }
    
    
    // Handle changes in AWS Identity. This can occur when the authentication state changes.
    // Handle a change in the AWS Cognito Identity, such as when an unauthenticated user creates an account.
    @objc func identityDidChange(notification: NSNotification?)
    {
        if let notification = notification
        {
            if let userInfo = notification.userInfo as? [String: AnyObject]
            {
                print("AWSCognito Identity changed from: \(userInfo[AWSCognitoNotificationPreviousId]) to: \(userInfo[AWSCognitoNotificationNewId])")
            }
        }
    }
    
    
}