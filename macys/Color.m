//
//  Color.m
//  macys
//
//  Created by ws233 on 22.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "Color.h"

@implementation Color

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
        id colorId = [self valueForKey:@"id" fromDictionary:dictionary];    // from database
        if (!colorId) {
            [self valueForKey:NSStringFromSelector(@selector(colorId)) fromDictionary:dictionary];  // from json
        }
        self.colorId = colorId;
        self.name = [self valueForKey:NSStringFromSelector(@selector(name)) fromDictionary:dictionary];
        self.rgb = [self valueForKey:NSStringFromSelector(@selector(rgb)) fromDictionary:dictionary];
    }
    return self;
}

@end
