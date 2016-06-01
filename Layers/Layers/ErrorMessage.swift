//
//  ErrorMessage.swift
//  Layers
//
//  Created by David Hodge on 5/30/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

extension NSError
{
    func formattedMessage() -> String?
    {
        if let errorString = self.userInfo["message"] as? String
        {
            return errorString
        }
        
        return self.localizedDescription
    }
}