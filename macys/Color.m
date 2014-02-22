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
        self.colorId = dictionary[@"id"];
        self.name = dictionary[NSStringFromSelector(@selector(name))];
        self.rgb = dictionary[NSStringFromSelector(@selector(rgb))];
    }
    return self;
}

@end
