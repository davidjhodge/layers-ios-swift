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

private let kAWSCognitoAppClientId = "22lne1f5vp57ls55bkmifp06ir"
private let kAWSCognitoAppClientSecret = "1qq3jup3mg7qq3ekbnok3tgkecbjlkr6gke9fqa8tfa4spdl4qbj"
private let kAWSCognitoIdentityPoolId = "us-east-1:7a62ae60-d5ab-44a9-a224-c9b5167fc932"
private let kAWSCognitoUserPoolId = "us-east-1_JrNu7NtLS"
private let kAWSCognitoUserPoolKey = "kUserPool"
private let kAWSSNSApplicationARN = "arn:aws:sns:us-east-1:843366835636:app/APNS_SANDBOX/Layers_Development"

private let kAWSCognitoUserPoolProvider = "cognito-idp.us-east-1.amazonaws.com/\(kAWSCognitoUserPoolId)"

class AWSManager: NSObject, AWSIdentityProviderManager
{
    // Static variable to allow single access to the service.
    static let defaultManager = AWSManager()
    
    // Access the Keychain
    private let keychain: Keychain = Keychain(service: NSBundle.mainBundle().bundleIdentifier!)
    
    var credentialsProvider: AWSCognitoCredentialsProvider!
    
    var userPool: AWSCognitoIdentityUserPool!

    var socialLoginDict: Dictionary<String,String>?

    var openIdToken: String?
    
    override init()
    {
        super.init()
        
        AWSLogger.defaultLogger().logLevel = .Error

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
        
        self.configureUserPool()
    }
    
    func configureUserPool()
    {
        // AWS User Pools
        let userPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: kAWSCognitoAppClientId, clientSecret: kAWSCognitoAppClientSecret, poolId: kAWSCognitoUserPoolId)
        AWSCognitoIdentityUserPool.registerCognitoIdentityUserPoolWithUserPoolConfiguration(userPoolConfiguration, forKey:kAWSCognitoUserPoolKey)
        userPool = AWSCognitoIdentityUserPool(forKey: kAWSCognitoUserPoolKey)
    }
    
    func loginMap() -> [String:String]?
    {
        var dict = Dictionary<String,String>()
        
        if FBSDKAccessToken.currentAccessToken() != nil
        {
            dict[AWSIdentityProviderFacebook] = FBSDKAccessToken.currentAccessToken().tokenString
        }
        
        if let userPoolId = keychain[kAWSCognitoUserPoolProvider]
        {
            dict[kAWSCognitoUserPoolProvider] = userPoolId
        }
        
        if dict.keys.count == 0
        {
            return nil
        }
        
        return dict
    }
    
    func isAuthenticated() -> Bool
    {
        if FBSDKAccessToken.currentAccessToken() != nil || keychain[kAWSCognitoUserPoolProvider] != nil
        {
            return true
        }
        
        return false
    }
    
    
    // MARK: Token Management
    func fetchOpenIdToken(completion: LRCompletionBlock?)
    {
        if let openIdToken: String = openIdToken
        {
            if let completion = completion
            {
                completion(success: true, error: nil, response: openIdToken)
                
                return
            }
        }
        
        fetchIdentityId({ (success, error, response) -> Void in
            
            if success
            {
                if let identityId = response as? String
                {
                    let request = AWSCognitoIdentityGetOpenIdTokenInput()
                    
                    request.identityId = identityId
                    
                    request.logins = self.loginMap()
                    
                    AWSCognitoIdentity.defaultCognitoIdentity().getOpenIdToken(request, completionHandler: { (response, error) -> Void in
                        
                        if error != nil
                        {
                            log.error(error?.localizedDescription)
                        }
                        else
                        {
                            // Success
                            if let tokenResponse: AWSCognitoIdentityGetOpenIdTokenResponse = response
                            {
                                if let openIdToken = tokenResponse.token,
                                    let newIdentityId = tokenResponse.identityId
                                {
                                    if let completion = completion
                                    {
                                        completion(success: true, error: nil, response: openIdToken)
                                        
                                        // Reset identity id
                                        if self.credentialsProvider.identityProvider.identityId != nil
                                        {
                                            self.credentialsProvider.identityProvider.identityId = newIdentityId
                                        }
                                        
                                        // Store OpenIdToken Locally
                                        self.openIdToken = openIdToken
                                        
                                        // Refresh Token after 1 hour
                                        self.refreshOpenIdTokenAfterOneHour()
                                    }
                                }
                            }
                        }
                    })
                }
            }
            else
            {
                log.error(error)
            }
        })

    }
    
    func refreshOpenIdTokenAfterOneHour()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.performSelector(#selector(self.refreshOpenIdToken), withObject: nil, afterDelay: 3600.0)
        })
    }
    
    func refreshOpenIdToken()
    {
        credentialsProvider.invalidateCachedTemporaryCredentials()
        
        openIdToken = nil
        
        fetchOpenIdToken({ (success, error, response) -> Void in
        
            if success
            {
                if let newToken = response as? String
                {
                    self.openIdToken = newToken
                    
                    // Set new timer to refresh the next hour
                    self.refreshOpenIdTokenAfterOneHour()
                }
                else
                {
                    log.error("Token Refresh Error. Will Attempt Refresh.")
                    
                    self.performSelector(#selector(self.refreshOpenIdToken), withObject: nil, afterDelay: 30)
                }
            }
        })
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
            AWSCognito.defaultCognito().registerDevice(deviceToken)

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
                    
                    self.automaticSignIn(email, password: password, autoSignInCompletionHandler: { (success, error, response) -> Void in
                      
                        if let completion = completionHandler
                        {
                            completion(success: success, error: error, response: response)
                        }
                        
                    })
                }
                
                return nil
            })
        }
    }
    
    func automaticSignIn(email: String, password: String, autoSignInCompletionHandler: LRCompletionBlock?)
    {
        signInToUserPool(email, password: password, completionHandler: { (success, error, response) -> Void in
          
            if let completion = autoSignInCompletionHandler
            {
                if let tokenString = response as? String
                {
                    self.keychain[kAWSCognitoUserPoolProvider] = tokenString
                    
                    self.syncLoginCredentials(nil)
                }

                completion(success: success, error: error, response: response)
            }
            
        })
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
//                            let accessToken = session.accessToken?.tokenString
//                            let idToken = session.idToken?.tokenString
//                            let refreshToken = session.refreshToken?.tokenString
                            
                            if let token = session.idToken?.tokenString
                            {
                                self.keychain[kAWSCognitoUserPoolProvider] = token
                                
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
    
    // Facebook Registration
    func registerFacebookToken()
    {
        if let facebookToken = FBSDKAccessToken.currentAccessToken().tokenString
        {
            keychain[AWSIdentityProviderFacebook] = facebookToken
            
            syncLoginCredentials(nil)
        }
    }
    
    func syncLoginCredentials(completionHandler: LRCompletionBlock?)
    {
        socialLoginDict = loginMap()
        
        if isAuthenticated()
        {
            credentialsProvider.identityProvider.logins().continueWithBlock( { (task: AWSTask!) -> AnyObject! in
                
                if task.error != nil
                {
                    if let completion = completionHandler
                    {
                        completion(success: false, error: task.error?.localizedDescription, response: nil)
                    }
                    
                    log.error(task.error?.localizedDescription)
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: true, error: nil, response: task.result)
                    }
                    
                    log.debug("Logins Synced.")
                }
                
                return AWSTask(result: task.result)
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(success: false, error:"Login Credentials cannot sync because user is not logged in.", response: nil)
            }
        }
    }
    
    func clearAWSCache()
    {
        // Clear Keychain
        keychain[kAWSCognitoUserPoolProvider] = nil
        keychain[AWSIdentityProviderFacebook] = nil
        
        syncLoginCredentials(nil)
        
        // Clear AWS Datasets
        AWSCognito.defaultCognito().wipe()
        
        // Clear AWS Cognito Temporary Credentials
        credentialsProvider.invalidateCachedTemporaryCredentials()
        
//        syncLoginCredentials({ (success, error, response) -> Void in
//            // When logins map has been cleared, clear al credentials
//            
//            // Clear AWS Datasets
//            AWSCognito.defaultCognito().wipe()
//            
//            // Clear AWS Cognito Temporary Credentials
//            self.credentialsProvider.clearKeychain()
//        })
    }
    
    
    // Handle changes in AWS Identity. This can occur when the authentication state changes.
    // Handle a change in the AWS Cognito Identity, such as when an unauthenticated user creates an account.
    @objc func identityDidChange(notification: NSNotification?)
    {
        if let notification = notification
        {
            if let userInfo = notification.userInfo as? [String: AnyObject]
            {
                if let newId = userInfo[AWSCognitoNotificationNewId] as? String
                {
                    print("AWSCognito Identity changed from: \(userInfo[AWSCognitoNotificationPreviousId]) to: \(newId)")
                    
                    if credentialsProvider.identityProvider.identityId != nil
                    {
                        credentialsProvider.identityProvider.identityId = newId
                    }
                    
                    openIdToken = nil
                }
            }
        }
    }
    
    
}