//
//  NSAttributedString+Pricing.h
//  Layers
//
//  Created by David Hodge on 3/16/16.
//  Copyright © 2016 Layers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Pricing)

+ (NSAttributedString *)priceStringWithRetailPrice:(NSNumber *)retailPrice salePrice:(NSNumber *)salePrice;

@end
