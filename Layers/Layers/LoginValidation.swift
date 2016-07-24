//
//  LoginValidation.swift
//  Layers
//
//  Created by David Hodge on 7/23/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

func isValidEmail(email: String) -> Bool
{
    return (email.containsString("@") && email.containsString("."))
}

func isValidPassword(password: String) -> Bool
{
    return password.characters.count > 6
}