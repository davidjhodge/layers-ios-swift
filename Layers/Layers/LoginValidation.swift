//
//  LoginValidation.swift
//  Layers
//
//  Created by David Hodge on 7/23/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

func isValidEmail(_ email: String) -> Bool
{
    return (email.contains("@") && email.contains("."))
}

func isValidPassword(_ password: String) -> Bool
{
    return password.characters.count > 6
}
