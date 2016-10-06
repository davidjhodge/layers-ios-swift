//
//  OpenSource.swift
//  Layers
//
//  Created by David Hodge on 6/18/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

struct OpenSourceLibrary
{
    var name: String?
    
    var licenseDescription: String?
    
    init(name: String, licenseDescription: String)
    {
        self.name = name
        
        self.licenseDescription = licenseDescription
    }
}


class OpenSource
{
    static func openSourceLibraries() -> Array<OpenSourceLibrary>
    {
        var contentsDict: NSDictionary?
        
        // Reference library descriptions
        if let path: String = Bundle.main.path(forResource: "OpenSourceList", ofType: "plist")
        {
            if let dict = NSDictionary(contentsOfFile: path)
            {
                contentsDict = dict
            }
        }
        
        var libraries: Array<OpenSourceLibrary> = Array<OpenSourceLibrary>()
        
        if let dict = contentsDict
        {
            if let content = dict["Alamofire"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "Alamofire", licenseDescription: content))
            }
            
            if let content = dict["AWS Mobile SDK for iOS"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "AWS Mobile SDK for iOS", licenseDescription: content))
            }
            
            if let content = dict["Bolts"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "Bolts", licenseDescription: content))
            }
            
            if let content = dict["Cosmos"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "Cosmos", licenseDescription: content))
            }
            
            if let content = dict["DACircularProgress"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "DACircularProgress", licenseDescription: content))
            }
            
            if let content = dict["DeepLinkKit"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "DeepLinkKit", licenseDescription: content))
            }
            
            if let content = dict["Facebook SDK for iOS"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "Facebook SDK for iOS", licenseDescription: content))
            }
            
            if let content = dict["IDMPhotoBrowser"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "IDMPhotoBrowser", licenseDescription: content))
            }
            
            if let content = dict["KeychainAccess"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "KeychainAccess", licenseDescription: content))
            }
            
            if let content = dict["MBProgressHUD"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "MBProgressHUD", licenseDescription: content))
            }
            
            if let content = dict["NHAlignmentFlowLayout"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "NHAlignmentFlowLayout", licenseDescription: content))
            }
            
            if let content = dict["ObjectMapper"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "ObjectMapper", licenseDescription: content))
            }
            
            if let content = dict["pop"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "pop", licenseDescription: content))
            }
            
            if let content = dict["SDWebImage"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "SDWebImage", licenseDescription: content))
            }
            
            if let content = dict["SwiftRangeSlider"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "SwiftRangeSlider", licenseDescription: content))
            }
            
            if let content = dict["SwiftyBeaver"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "SwiftyBeaver", licenseDescription: content))
            }
            
            if let content = dict["SwiftyJSON"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "SwiftyJSON", licenseDescription: content))
            }
            
            if let content = dict["UITextView+Placeholder"] as? String
            {
                libraries.append(OpenSourceLibrary(name: "UITextView+Placeholder", licenseDescription: content))
            }
        }
        
        return libraries
    }
}
