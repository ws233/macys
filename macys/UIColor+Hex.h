//
//  UIColor+Hex.h
//  reciept-organizer
//
//  Created by mmakankov on 22.01.14.
//  Copyright (c) 2014 ws233. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

- (NSUInteger)colorCode;
+ (UIColor *)colorFromRGB:(NSUInteger)rgbValue;

@end
