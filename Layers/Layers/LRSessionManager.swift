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

import FBSDKLoginKit

let kLRAPIBase = "http://52.22.85.12:8000/"
let kAccessToken = "kAccessToken"
let kCurrentUser = "kCurrentUser"

let productCollectionPageSize = 20

typealias LRCompletionBlock = ((success: Bool, error: String?, response:AnyObject?) -> Void)
typealias LRJsonCompletionBlock = ((success: Bool, error: String?, response:JSON?) -> Void)

class LRSessionManager: NSObject
{
    // Static variable to handle all networking and caching activities
    static let sharedManager: LRSessionManager = LRSessionManager()
    
    // Intialized in the init method and is never deallocated. It is assumed to always exist
    var networkManager: Manager!
    
    // Background queue to handle API responses
    private let backgroundQueue: dispatch_queue_t = dispatch_queue_create("Session Background", DISPATCH_QUEUE_CONCURRENT)
    
    // Access the Keychain
    private let keychain: Keychain = Keychain(service: "Layers")
        
    // MARK: Initialization
    override init ()
    {
        super.init()
        
        //Log debugging
        log.debug("Initializing Session")
        
        //initialize alamofire network manager
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPMaximumConnectionsPerHost = 10
        configuration.timeoutIntervalForRequest = 30
        
        networkManager = Alamofire.Manager(configuration: configuration)
        
        resumeSession()
    }
    
    //MARK: Managing Account Credentials
    
    func resumeSession()
    {
        // Retrieves cognito identity locally if one is cached, and from the AWS Cognito Remote service if none exists
        AWSManager.defaultManager.fetchIdentityId({ (success, error, response) -> Void in
          
            if success
            {
                log.debug("Successfully retrieved identity token from AWS.")
            }
            else
            {
                if let errorMessage = error
                {
                    log.debug(errorMessage)
                    
                    // If identityId does not exist, clear all existing credentials to avoid an incomplete state
                    self.logout()

                }
            }
        })
    }
    
    func isAuthenticated() -> Bool
    {
        return AWSManager.defaultManager.isAuthorized()
    }

    func logout()
    {
        // Clear Facebook Token if needed
        if FBSDKAccessToken.currentAccessToken() != nil
        {
            FBSDKLoginManager().logOut()
        }
        
        AWSManager.defaultManager.clearAWSCache()
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
    
    // MARK: Authorization
    
    func register(email: String, password: String, completionHandler: LRCompletionBlock?)
    {
        AWSManager.defaultManager.registerToUserPool(email, password: password, completionHandler: { (success, error, response) -> Void in
            
            if let completion = completionHandler
            {
                // Pass completion block returned from AWS Service
                completion(success: success, error: error, response: response)
            }
        })
    }
    
    func signIn(email: String, password: String, completionHandler: LRCompletionBlock?)
    {
        AWSManager.defaultManager.signInToUserPool(email, password: password, completionHandler: { (success, error, response) -> Void in
         
            if let completion = completionHandler
            {
                // Pass completion block returned from AWS Service
                completion(success: success, error: error, response: response)
            }
        })
    }
    
//        //Send API
//        let postBody = ["email":        email,
//                        "password":     password,
//                        "first_name":   firstName,
//                        "last_name":    lastName,
//                        "gender":       gender,
//                        "age":          age]

    
    func registerWithFacebook(completion: LRJsonCompletionBlock?)
    {
        // The currentAccessToken() should be retrieved from Facebook in the View Controller that the login dialogue is shown from.
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // Add this login to an existing cognito identity
            AWSManager.defaultManager.syncLoginCredentials([AWSIdentityProviderFacebook: FBSDKAccessToken.currentAccessToken().tokenString])
            
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
    
    // MARK: Push Notifications
    func registerForPushNotifications(deviceToken: NSData?, completionHandler: LRCompletionBlock?)
    {
        AWSManager.defaultManager.registerWithSNS(deviceToken, completionHandler: { (success, error, response) -> Void in
            
            if let completion = completionHandler
            {
                completion(success: success, error: error, response: response)
            }
        })
    }
    
    func registerForRemoteNotifications()
    {
        let readAction: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        readAction.identifier = "READ_IDENTIFIER"
        readAction.title = "Read"
        readAction.activationMode = .Foreground
        readAction.destructive = false
        readAction.authenticationRequired = true
        
        let messageCategory = UIMutableUserNotificationCategory()
        messageCategory.identifier = "MESSAGE_CATEGORY"
        messageCategory.setActions([readAction], forContext: .Default)
        messageCategory.setActions([readAction], forContext: .Minimal)
        
        let categories: Set<UIUserNotificationCategory> = NSSet(object: messageCategory) as! Set<UIUserNotificationCategory>
        
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: categories)
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
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
            var requestString = "products/?page=\(page)&per_page=\(productCollectionPageSize)"
            
            if FilterManager.defaultManager.getCurrentFilter().hasActiveFilters()
            {
                let paramsString = FilterManager.defaultManager.filterParamsAsString()
                
                requestString = requestString.stringByAppendingString("&\(paramsString)")
            }
            
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: APIUrlAtEndpoint(requestString))
                        
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
    
    // MARK: Filtering
    
    func loadCategories(completionHandler: LRCompletionBlock?)
    {
        let request = NSMutableURLRequest(URL: APIUrlAtEndpoint("categories"))
        
        request.HTTPMethod = "GET"
        
        sendAPIRequest(request, authorization: false, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    let categories = Mapper<CategoryResponse>().mapArray(jsonResponse.arrayObject)
                    
                    if let completion = completionHandler
                    {
                        completion(success: true, error: error, response: categories)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
    }
    
    func loadBrands(completionHandler: LRCompletionBlock?)
    {
        let request = NSMutableURLRequest(URL: APIUrlAtEndpoint("brands"))
        
        request.HTTPMethod = "GET"
        
        sendAPIRequest(request, authorization: false, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    let brands = Mapper<BrandResponse>().mapArray(jsonResponse.arrayObject)
                    
                    if let completion = completionHandler
                    {
                        completion(success: true, error: error, response: brands)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
    }
    
    func loadRetailers(completionHandler: LRCompletionBlock?)
    {
        let request = NSMutableURLRequest(URL: APIUrlAtEndpoint("retailers"))
        
        request.HTTPMethod = "GET"
        
        sendAPIRequest(request, authorization: false, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    let retailers = Mapper<RetailerResponse>().mapArray(jsonResponse.arrayObject)
                        
                    if let completion = completionHandler
                    {
                            completion(success: true, error: error, response: retailers)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
    }
    
    func loadColors(completionHandler: LRCompletionBlock?)
    {
        let request = NSMutableURLRequest(URL: APIUrlAtEndpoint("colors"))
        
        request.HTTPMethod = "GET"
        
        sendAPIRequest(request, authorization: false, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    let colors = Mapper<ColorResponse>().mapArray(jsonResponse.arrayObject)
                    
                    if let completion = completionHandler
                    {
                        completion(success: true, error: error, response: colors)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
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
            // If user is authenticated, fetch token and authorize request
            if authorization && isAuthenticated()
            {
                AWSManager.defaultManager.fetchAccessToken({ (success, error, response) -> Void in
                    
                    if success
                    {
                        if let accessToken = response as? String
                        {
                            networkRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
                        }
                    }
                    else
                    {
                        log.debug(error)
                    }
                })
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