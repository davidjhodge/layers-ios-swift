//
//  NSAttributedString+Pricing.m
//  Layers
//
//  Created by David Hodge on 3/16/16.
//  Copyright © 2016 Layers. All rights reserved.
//

#import "NSAttributedString+Pricing.h"
#import <UIKit/UIKit.h>
#import "Layers-Swift.h"

@implementation NSAttributedString (Pricing)

+ (NSAttributedString *)priceStringWithRetailPrice:(NSNumber *)retailPrice salePrice:(NSNumber *)salePrice
{
    if (!retailPrice) return [[NSAttributedString alloc] init];
        
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
    
    //Retail String
    NSString *retailRawString = [NSString stringWithFormat:@"%.02f", [retailPrice floatValue]];
    
    NSAttributedString *retailString = [[NSAttributedString alloc] initWithString:retailRawString attributes:@{
                                                                                                           NSFontAttributeName: [UIFont systemFontOfSize:10.0],
                                                                                                           NSForegroundColorAttributeName:[Color DarkTextColor],
                                                                                                           NSStrikethroughStyleAttributeName:
                                                                                                               [NSNumber numberWithInteger:NSUnderlineStyleSingle]}
                                        ];
    
    
    if (salePrice)
    {
        //Sale String
        NSString *saleRawString = [NSString stringWithFormat:@"%.02f ", [salePrice floatValue]];
        
        NSAttributedString *saleString = [[NSAttributedString alloc] initWithString:saleRawString attributes:@{
                                                                                                               NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0],
                                                                                                               NSForegroundColorAttributeName:[Color RedColor]}];
        
        [finalString appendAttributedString:saleString];
    }
    
    [finalString appendAttributedString:retailString];
    
    return finalString;
}

@end
