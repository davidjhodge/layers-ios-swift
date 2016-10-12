//
//  SharedNetworkingUtilities.swift
//  Layers
//
//  Created by David Hodge on 10/12/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import SwiftyJSON

//private let kLRAPIBase = "https://api.trylayers.com/"
private let kLRAPIBase = "http://52.24.175.141:8000/"

//private let productCollectionPageSize = 12

typealias LRCompletionBlock = ((_ success: Bool, _ error: String?, _ response:Any?) -> Void)
typealias LRJsonCompletionBlock = ((_ success: Bool, _ error: String?, _ response:JSON?) -> Void)

// MARK: API Helpers
func APIUrlAtEndpoint(_ endpointPath: String?) -> URL
{
    if let path = endpointPath
    {
        return URL(string: kLRAPIBase + path)!
    }
    
    return URL(string: "")! // Make sure this does not fail
}
