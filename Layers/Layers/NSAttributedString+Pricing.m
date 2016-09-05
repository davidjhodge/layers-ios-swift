//
//  NSAttributedString+Pricing.m
//  Layers
//
//  Created by David Hodge on 3/16/16.
//  Copyright © 2016 Layers. All rights reserved.
//

#import "NSAttributedString+Pricing.h"
#import "Layers-Swift.h"

CGFloat const kRetailStringSizeStrikethroughSmall = 12.0;
CGFloat const kRetailStringSizeMedium = 15.0;
CGFloat const kRetailStringSizeLarge = 17.0;

CGFloat const kSaleStringSizeMedium = 15.0;
CGFloat const kSaleStringSizeLarge = 17.0;

@implementation NSAttributedString (Pricing)

+ (NSAttributedString *)priceStringWithRetailPrice:(NSNumber *)retailPrice salePrice:(NSNumber *)salePrice
{
    if (!retailPrice) return [[NSAttributedString alloc] init];
        
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
    
    //Retail String
    NSString *retailRawString = @"";
    
    if ([retailPrice floatValue] == [retailPrice integerValue])
    {
        retailRawString = [NSString stringWithFormat:@"%ld", (long)[retailPrice integerValue]];
    }
    else
    {
        retailRawString = [NSString stringWithFormat:@"%.02f ", [retailPrice floatValue]];
    }
    
    // If sale price is the same as the retail price, just show the retail price
    if ([retailPrice floatValue] == [salePrice floatValue])
    {
        return [[NSAttributedString alloc] initWithString:retailRawString attributes:@{NSFontAttributeName: [Font PrimaryFontRegularWithSize:kRetailStringSizeMedium],
            NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    
    NSAttributedString *retailString = [[NSAttributedString alloc] initWithString:retailRawString attributes:@{
                                                                                                                                            NSFontAttributeName: [Font PrimaryFontRegularWithSize:kRetailStringSizeStrikethroughSmall],
                                                                                                           NSForegroundColorAttributeName:[Color DarkTextColor],
                                                                                                           NSStrikethroughStyleAttributeName:
                                                                                                               [NSNumber numberWithInteger:NSUnderlineStyleSingle]}
                                        ];
    
    [finalString appendAttributedString:retailString];

    if (salePrice)
    {
        //Sale String
        NSString *saleRawString = @"";
        
        if ([salePrice floatValue] == [salePrice integerValue])
        {
            saleRawString = [NSString stringWithFormat:@"%ld", (long)[salePrice integerValue]];
        }
        else
        {
            saleRawString = [NSString stringWithFormat:@"%.02f ", [salePrice floatValue]];
        }
        
        NSAttributedString *saleString = [[NSAttributedString alloc] initWithString:saleRawString attributes:@{
                                                                                                               NSFontAttributeName: [Font PrimaryFontRegularWithSize:kSaleStringSizeMedium],
                                                                                                               NSForegroundColorAttributeName:[Color RedColor]}];
        
        NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName: [Font PrimaryFontRegularWithSize:15.0]}];
        [finalString appendAttributedString:space];
        [finalString appendAttributedString:saleString];
    }
    
    return finalString;
}

+ (NSAttributedString *)priceStringWithRetailPrice:(NSNumber *)retailPrice size:(CGFloat)size strikethrough:(BOOL)strikethrough
{
    if (!retailPrice) return [[NSAttributedString alloc] init];
    
    CGFloat textSize = size;
    
    if (!size || textSize == 0 || textSize < 0)
    {
        textSize = kRetailStringSizeMedium;
    }
    
    NSString *retailString = @"";
    if ([retailPrice floatValue] == [retailPrice integerValue])
    {
        retailString = [NSString stringWithFormat:@"%ld", (long)[retailPrice integerValue]];
    }
    else
    {
        retailString = [NSString stringWithFormat:@"%.02f ", [retailPrice floatValue]];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:retailString attributes:@{
                                                                                                                NSFontAttributeName: [Font PrimaryFontRegularWithSize:size],
                                                                                                                NSForegroundColorAttributeName:[Color DarkTextColor]
                                                                                                                }];
    
    if (strikethrough == YES)
    {
        [attributedString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, retailString.length)];
    }
    
    return (NSAttributedString *)attributedString;
}

+ (NSAttributedString *)priceStringWithSalePrice:(NSNumber *)salePrice size:(CGFloat)size
{
    if (!salePrice) return [[NSAttributedString alloc] init];
    
    CGFloat textSize = size;
    
    if (!size || textSize == 0 || textSize < 0)
    {
        textSize = kRetailStringSizeMedium;
    }
    
    NSString *saleString = @"";
    if ([salePrice floatValue] == [salePrice integerValue])
    {
        saleString = [NSString stringWithFormat:@"%ld", (long)[salePrice integerValue]];
    }
    else
    {
        saleString = [NSString stringWithFormat:@"%.02f ", [salePrice floatValue]];
    }
    
    return [[NSAttributedString alloc] initWithString:saleString attributes:@{
                                                                                 NSFontAttributeName: [Font PrimaryFontRegularWithSize:kSaleStringSizeMedium],
                                                                                 NSForegroundColorAttributeName:[Color RedColor]}];
}

@end
