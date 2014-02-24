//
//  UIColor+Hex.m
//  reciept-organizer
//
//  Created by mmakankov on 22.01.14.
//  Copyright (c) 2014 ws233. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

- (NSUInteger)colorCode
{
    CGFloat red, green, blue;
    if ([self getRed:&red green:&green blue:&blue alpha:NULL])
    {
        NSUInteger redInt = (NSUInteger)(red * 255 + 0.5);
        NSUInteger greenInt = (NSUInteger)(green * 255 + 0.5);
        NSUInteger blueInt = (NSUInteger)(blue * 255 + 0.5);
        
        return (redInt << 16) | (greenInt << 8) | blueInt;
    }
    return 0;
}

+ (UIColor *)colorFromRGB:(NSUInteger)rgbValue {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0f
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0f
                            blue:((float)(rgbValue & 0xFF))/255.0f
                           alpha:1.0];
}

@end
