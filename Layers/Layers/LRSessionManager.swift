//
//  LRSessionManager.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import ObjectMapper
import KeychainAccess

import AWSCognitoIdentityProvider
import AWSCore
import AWSCognito

import FBSDKLoginKit

let kLRAPIBase = "http://52.22.85.12:8000/"
let kAccessToken = "kAccessToken"
let kCurrentUser = "kCurrentUser"

//AWS
private let kAWSCognitoClientId = "5gjvi9e5ikmntbduka8mp0jf9q"
private let kAWSCognitoClientSecret = "5gjvi9e5ikmntbduka8mp0jf9q"
private let kAWSCognitoPoolId = "us-east-1:c7d2ab80-046f-4b0d-8344-32db54981782"
private let kAWSUserPoolId = "us-east-1_dHgDcpP9d"

let productCollectionPageSize = 20

typealias LRCompletionBlock = ((success: Bool, error: String?, response:AnyObject?) -> Void)
typealias LRJsonCompletionBlock = ((success: Bool, error: String?, response:JSON?) -> Void)

class LRSessionManager
{
    // Static variable to handle all networking and caching activities
    static let sharedManager: LRSessionManager = LRSessionManager()
    
    // Intialized in the init method and is never deallocated. It is assumed to always exist
    var networkManager: Manager!
    
    // Background queue to handle API responses
    private let backgroundQueue: dispatch_queue_t = dispatch_queue_create("Session Background", DISPATCH_QUEUE_CONCURRENT)
    
    // Access the Keychain
    private let keychain: Keychain = Keychain(service: "Layers")
    
    var currentUser: User?
    
    var accessToken: String?
    var secretToken: String?
    
    var credentialsProvider: AWSCognitoCredentialsProvider!
    
    var AWSCompletionHandler: AWSContinuationBlock?

    
    // MARK: Initialization
    init ()
    {
        //Log debugging
        log.debug("Initializing Session")
        
        //initialize alamofire network manager
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPMaximumConnectionsPerHost = 10
        configuration.timeoutIntervalForRequest = 30
        
        networkManager = Alamofire.Manager(configuration: configuration)
        
        // Configures AWS Cognito and User Pools
        configureAWS()
        
        //Detect Change in Identity when an unauthenticated user logs in (if an account for that login already exists)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(identityDidChange), name: AWSCognitoIdentityIdChangedNotification, object: nil)
                
        // Restore session credentials
        resumeSession()
    }
    
    private func configureAWS()
    {
        //AWS
        AWSLogger.defaultLogger().logLevel = .Verbose
        
        credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: kAWSCognitoPoolId)
        let defaultServiceConfiguration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
    }
    
    //MARK: Managing Account Credentials
    
    func resumeSession()
    {
        // Retrieves cognito identity locally if one is cached, and from the AWS Cognito Remote service if none exists
        refreshIdentityId()
        
        if FBSDKAccessToken.currentAccessToken() != nil
        {
            syncCredentials([AWSIdentityProviderFacebook: FBSDKAccessToken.currentAccessToken().tokenString])
        }
    }
    
    func syncCredentials(logins: [NSObject: AnyObject]?)
    {
        var merge = [NSObject : AnyObject]()
        
        //Add existing logins
        if let previousLogins = self.credentialsProvider?.logins {
            merge = previousLogins
        }
        
        //Add new logins
        if let unwrappedLogins = logins {
            for (key, value) in unwrappedLogins {
                merge[key] = value
            }
            self.credentialsProvider?.logins = merge
        }
    }
    
    func logout()
    {
        // Clear Facebook Token if needed
        if FBSDKAccessToken.currentAccessToken() != nil
        {
            FBSDKLoginManager().logOut()
        }
        
        // Clear AWS Datasets
        AWSCognito.defaultCognito().wipe()
        
        // Clear AWS Cognito Credentials
        credentialsProvider.logins = nil
        credentialsProvider.clearKeychain()
    }
    
//    /**
//     Restores the current session credentials from keychain.
//    */
//    private func restoreCredentials()
//    {
//        log.debug("Attempting to restore session.")
//        
//        if let token = keychain[kAccessToken], userJson = keychain[kCurrentUser]
//        {
//            currentUser = Mapper<User>().map(userJson)
//            accessToken = token
//            
//            log.debug("Successfully restored session.")
//        }
//        else
//        {
//            log.warning("Failed to restore session.")
//            
//            clearCredentials()
//        }
//    }
//    
//    /**
//    Saves the current session credentials to keychain.
//    */
//    private func saveCredentials()
//    {
//        if let userToken = accessToken, user = currentUser
//        {
//            log.debug("Saving session")
//            
//            keychain[kAccessToken] = userToken
//            keychain[kCurrentUser] = Mapper().toJSONString(user, prettyPrint: false)
//        }
//        else
//        {
//            log.error("Invalid Credentials. Session Cleared")
//            
//            keychain[kAccessToken] = nil
//            keychain[kCurrentUser] = nil
//        }
//    }
//    
//    private func clearCredentials()
//    {
//        accessToken = nil
//        
//        currentUser = nil
//        
//        saveCredentials()
//    }
//    
//    func logout()
//    {
//        clearCredentials()
//    }
//    
//    func isLoggedIn() -> Bool
//    {
//        if accessToken != nil && currentUser != nil
//        {
//            return true
//        }
//        else
//        {
//            accessToken = nil
//            currentUser = nil
//            
//            log.debug("User is not logged in.")
//        }
//        
//        return false
//    }
    
    // MARK: API Access
    
    /**
    *   Register using AWSCognito
    */
    func registerUnauthorized()
    {
        // If no identity token is cached, retreive one from AWS Cognito
        var cognitoIdentifier = ""
        
        if let cognitoId = credentialsProvider.identityId
        {
            cognitoIdentifier = cognitoId
            
            log.debug("Cognito Identifier: \(cognitoIdentifier)")
        }
        else
        {
            refreshIdentityId()
        }
    }
    
    func refreshIdentityId()
    {
        // Retreives an existing cognito Id if one exists. If not, a new one is created
        credentialsProvider.getIdentityId().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
            
            if task.error != nil
            {
                log.debug("Error: \(task.error?.localizedDescription)")
            }
            else
            {
                // Success!
                let cognitoIdentifier = task.result as! String
                
                let logins = self.credentialsProvider.identityProvider.logins()
                
                log.debug("Cognito Identifier: \(cognitoIdentifier)")
                
            }
            
            return nil
        })
    }
    
    func registerAuthorized(email: String, password: String)
    {
        if email.characters.count > 0 && password.characters.count > 0
        {
//            pool.signUp(email, password: password, userAttributes: nil, validationData: nil).continueWithBlock( { (task: AWSTask) -> AnyObject! in
//              
//                if task.cancelled
//                {
//                    // Task Cancelled
//                    log.debug("Sign up task cancelled.")
//                }
//                else if task.error != nil
//                {
//                    log.error(task.error?.localizedDescription)
//                }
//                else
//                {
//                    let user: AWSCognitoIdentityUser = task.result as! AWSCognitoIdentityUser
//
//                }
//                
//                return nil
//            })

        }
    }
    
    /**
     *  Register a new user.
     */
//    func register(email: String, password: String, firstName: String, lastName: String, gender: String, age: Int, completion: LRCompletionBlock?)
//    {
//        // Error check each param
//        if email.characters.count == 0 || password.characters.count == 0
//        {
//            if let completionHandler = completion
//            {
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    
//                    completionHandler(success: false, error: "INCOMPLETE_FIELDS".localized, response: nil)
//                })
//            }
//            
//            return
//        }
//        
//        //Send API
//        let postBody = ["email":        email,
//                        "password":     password,
//                        "first_name":   firstName,
//                        "last_name":    lastName,
//                        "gender":       gender,
//                        "age":          age]
//        
//        sendAPIRequest(jsonRequest(APIUrlAtEndpoint("user/register"), HTTPMethod: "POST", json: postBody), authorization: false, completion: { (success, error, response) -> Void in
//            
//            if success
//            {
//                if let userJson = response?["user"]
//                {
//                    self.currentUser = Mapper<User>().map(userJson.dictionaryObject)
//                    
//                    self.accessToken = response?["token"].string
//                    
//                    self.saveCredentials()
//                    
//                    //Success
//                    if let completionHandler = completion
//                    {
//                        completionHandler(success: false, error: "NETWORK_ERROR_UNKNOWN".localized, response: nil)
//                    }
//                    
//                }
//                else
//                {
//                    self.clearCredentials()
//                    
//                    if let completionHandler = completion
//                    {
//                        completionHandler(success: false, error: "NETWORK_ERROR_UNKNOWN".localized, response: nil)
//                    }
//                }
//            }
//            else
//            {
//                self.clearCredentials()
//                
//                if let completionHandler = completion
//                {
//                    completionHandler(success: false, error: error, response: nil)
//                }
//            }
//        })
//    }
    
    func registerWithFacebook(completion: LRJsonCompletionBlock?)
    {
        // The currentAccessToken() should be retrieved from Facebook in the View Controller that the login dialogue is shown from.
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // Connect this Facebook account with the existing Amazon Cognito Identity
            self.credentialsProvider?.identityProvider.logins().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                
                if task.error != nil
                {
                    [AWSIdentityProviderFacebook: FBSDKAccessToken.currentAccessToken().tokenString]
                }
            
                return [AWSIdentityProviderFacebook: FBSDKAccessToken.currentAccessToken().tokenString]
            })

            // Get user information with Facebook Graph API
            let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, age_range, link, gender, locale, picture, timezone, updated_time, verified, friends, email"], HTTPMethod: "GET")
            
            request.startWithCompletionHandler({(connection:FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                
                if error == nil
                {
                    let attributes: Dictionary<String,AnyObject> = result as! Dictionary<String,AnyObject>
                    
                    let response = Mapper<FacebookUserResponse>().map(attributes)
                    
                    if let completionBlock = completion
                    {
                        completionBlock(success: true, error: nil, response: JSON(response!))
                    }
                }
                else
                {
                    if let completionBlock = completion
                    {
                        completionBlock(success: true, error: error.localizedDescription, response: nil)
                    }
                }
            })
        }
    }
    
    // MARK: Fetching Server Data
    func loadProduct(productId: NSNumber, completionHandler: LRCompletionBlock?)
    {
        if productId.integerValue >= 0
        {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: APIUrlAtEndpoint("products/\(productId.stringValue)"))
            
            request.HTTPMethod = "GET"
            
            sendAPIRequest(request, authorization: false, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        let product = Mapper<ProductResponse>().map(jsonResponse.dictionaryObject)
                        
                        if let completion = completionHandler
                        {
                            completion(success: success, error: error, response: product)
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    completion(success: false, error: "NO_PRODUCT_ID".localized, response: nil)
                })
            }
            
            return
        }
    }
    
    func loadProductCollection(page: Int, completionHandler: LRCompletionBlock?)
    {
        if page >= 0
        {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: APIUrlAtEndpoint("products/?page=\(page)&per_page=\(productCollectionPageSize)"))
            
            request.HTTPMethod = "GET"
            
            sendAPIRequest(request, authorization: false, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        let products = Mapper<ProductResponse>().mapArray(jsonResponse.arrayObject)
                        
                        if let completion = completionHandler
                        {
                            completion(success: success, error: error, response: products)
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(success: false, error: "INVALID_PARAMETERS".localized, response: nil)
            }
        }

    }
    
    func loadReviewsForProduct(productId: NSNumber, completionHandler: LRCompletionBlock?)
    {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: APIUrlAtEndpoint("products/\(productId.stringValue)"))
        
        request.HTTPMethod = "GET"
        
        sendAPIRequest(request, authorization: false, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    let product = Mapper<ProductResponse>().map(jsonResponse.dictionaryObject)
                    
                    
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: product)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: success, error: error, response: nil)
                }
            }
        })
    }
    
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
    
    // MARK: API Helpers
    func APIUrlAtEndpoint(endpointPath: String?) -> NSURL
    {
        if let path = endpointPath
        {
            return NSURL(string: kLRAPIBase.stringByAppendingString(path))!
        }
        
        return NSURL()
    }
    
    /**
    Create a JSON Request with HTTP Method and Body
    */
    private func jsonRequest(url: NSURL, HTTPMethod: String, json: AnyObject) -> NSMutableURLRequest
    {
        let jsonObject = JSON(json)
        
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = HTTPMethod
        
        let options = NSJSONWritingOptions(rawValue: 0)
        
        do {
            try request.HTTPBody = jsonObject.rawData(options: options)
        } catch {
            log.verbose("Failed to assign HTTP Post Body to request.")
        }
        
        return request
    }
    
    /**
    Sends a generic request to the API and either returns the desired result or handles errors dispatched from the server.
 
    This function calls the completion block on the method it was called on. You are responsible for calling completion blocks on the main thread.
    */
    private func sendAPIRequest(request: NSURLRequest, authorization: Bool, completion: LRJsonCompletionBlock?)
    {
        let startTime = NSDate().timeIntervalSince1970
        
        if let networkRequest = request.mutableCopy() as? NSMutableURLRequest
        {
            if authorization && (accessToken != nil)
            {
                networkRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
            }
            
            networkRequest.setValue("close", forHTTPHeaderField: "Connection")
            
            networkManager.request(networkRequest)
                .validate(contentType: ["application/json"]).responseString(encoding: NSUTF8StringEncoding) { (responseInfo: Response<String, NSError>) -> Void in
                    
                    //Process responses in a queue
                    dispatch_async(self.backgroundQueue, { () -> Void in
                        
                        let requestUrlString = request.URL?.absoluteString
                        let requestTimestamp = NSDate().timeIntervalSince1970 - startTime
                        
                        log.verbose("Request: \(requestUrlString!) returned in: \(requestTimestamp)")
                        
                        //Extract data from response string
                        if let data = responseInfo.result.value?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                        {
                            var jsonError: NSError?
                            let jsonObject = JSON(data: data, options: .AllowFragments, error: &jsonError)
                            
                            // Handle JSON parsing errors
                            if let jsonParsingError = jsonError
                            {
                                if let completionHandler = completion
                                {
                                    log.error("Networking Error: ", jsonParsingError.localizedDescription)
                                    
                                    completionHandler(success: false, error: jsonParsingError.localizedDescription, response: nil)
                                }
                                
                                return
                            }
                            
                            // Check for networking errors
                            if jsonObject["status"] == "error"
                            {
                                if let completionHandler = completion
                                {
                                    // Need to handle error
                                    completionHandler(success: false, error: "NETWORK_ERROR_UNKNOWN".localized, response: nil)
                                }
                                
                                return
                            }
                            
                            //SUCCESS
                            if let completionHandler = completion
                            {
                                completionHandler(success: true, error: nil, response: jsonObject)
                            }
                            
                        }
                        else
                        {
                            if let completionHandler = completion
                            {
                                if let errorMessage = responseInfo.result.error?.localizedDescription
                                {
                                    log.error("Networking Error: \(errorMessage)")
                                }
                                else
                                {
                                    log.error("NETWORK_ERROR_UNKNOWN".localized)
                                    completionHandler(success: false, error: "NETWORK_ERROR_UNKNOWN".localized, response: nil)
                                }
                            }
                        }
                    })
            }
        }
        else
        {
            if let completionHandler = completion
            {
                completionHandler(success: false, error: "The URL request made by the client is malformed.", response: nil)
            }
        }
    }
    
//    deinit
//    {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
}