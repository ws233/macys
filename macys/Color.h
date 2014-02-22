//
//  Color.h
//  macys
//
//  Created by ws233 on 22.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "Entity.h"
#import "UIColor+Hex.h"

@interface Color : Entity

@property (nonatomic) NSNumber *colorId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSNumber *rgb;

@end
