//
//  UINavigationItem+BackButton.m
//  Layers
//
//  Created by David Hodge on 4/16/16.
//  Copyright © 2016 Layers. All rights reserved.
//

#import "UINavigationItem+BackButton.h"

@implementation UINavigationItem (BackButton)

- (UIBarButtonItem *)backBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
