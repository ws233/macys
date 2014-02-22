//
//  Product.m
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "Product.h"
#import "Color.h"
#import "Base64.h"
#import "DataStore.h"

@implementation Product

- (id)init {
    
    NSDictionary *dictionary = @{@"productPhoto"    : [UIImagePNGRepresentation([UIImage imageNamed:@"macys_logo"]) base64EncodedString],
                                 @"name"            : @"New Product",
                                 @"description"     : @"Input Description here...",
                                 };
    self = [self initWithDictionary:dictionary];
    if (self) {
        
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
        NSString *imageString = dictionary[NSStringFromSelector(@selector(productPhoto))];
        NSData *imageData = [imageString isKindOfClass:[NSString class]] ? [NSData dataWithBase64EncodedString:imageString] : nil;
        self.productId = dictionary[@"id"];
        self.name = dictionary[NSStringFromSelector(@selector(name))];
        self.explonation = dictionary[@"description"];
        self.regularPrice = dictionary[NSStringFromSelector(@selector(regularPrice))];
        self.salePrice = dictionary[NSStringFromSelector(@selector(salePrice))];
        self.productPhoto = [UIImage imageWithData:imageData];
        self.colors = [[DataStore sharedInstance] colorsForProductId:self.productId.integerValue].allObjects.mutableCopy;
        //self.stores = dictionary[NSStringFromSelector(@selector(stores))];
    }
    return self;
}

- (Class)classForArrayObjectNamed:(NSString*)objectNamed {
    
    return [Color class];
}

@end