//
//  Product.m
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "Product.h"
#import "Color.h"
#import "Store.h"
#import "Base64.h"
#import "MCSDataStore.h"

@implementation Product

- (instancetype)init {
    
    NSDictionary *dictionary = @{@"productPhoto"    : [UIImagePNGRepresentation([UIImage imageNamed:@"macys_logo"]) base64EncodedString],
                                 @"name"            : @"New Product",
                                 @"description"     : @"Input Description here...",
                                 };
    self = [self initWithDictionary:dictionary];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    
    self = [super initWithDictionary:dictionary];
    if (self) {
        NSString *imageString = [self valueForKey:NSStringFromSelector(@selector(productPhoto)) fromDictionary:dictionary];
        NSData *imageData = [NSData dataWithBase64EncodedString:imageString];
        _productPhoto = [UIImage imageWithData:imageData];
        
        id productId = [self valueForKey:@"id" fromDictionary:dictionary];  // from data base
        if (!productId) {
            productId = [self valueForKey:NSStringFromSelector(@selector(productId)) fromDictionary:dictionary];  // from json
        }
        self.productId = productId;
        
        self.name = [self valueForKey:NSStringFromSelector(@selector(name)) fromDictionary:dictionary];
        
        id explonation = [self valueForKey:@"description" fromDictionary:dictionary];   // from database
        if (!explonation) {
            explonation = [self valueForKey:NSStringFromSelector(@selector(explonation)) fromDictionary:dictionary];    // from json
        }
        self.explonation = explonation;
        
        self.regularPrice = [self valueForKey:NSStringFromSelector(@selector(regularPrice)) fromDictionary:dictionary];
        self.salePrice = [self valueForKey:NSStringFromSelector(@selector(salePrice)) fromDictionary:dictionary];

        NSArray *colorsArray = dictionary[NSStringFromSelector(@selector(colors))];
        if ([colorsArray isKindOfClass:[NSArray class]]) {
            // read from json
            self.colors = [self objectsOfClass:[Color class] fromArray:colorsArray];
        } else {
            // read from database
            self.colors = [[MCSDataStore sharedInstance] colorsForProductId:self.productId.integerValue].allObjects.mutableCopy;
        }
        NSArray *storesArray = dictionary[NSStringFromSelector(@selector(stores))];
        if ([storesArray isKindOfClass:[NSArray class]]) {
            // read from json
            self.stores = [self objectsOfClass:[Store class] fromArray:storesArray];
        } else {
            // read from database
            self.stores = [[MCSDataStore sharedInstance] storesForProductId:self.productId.integerValue].allObjects.mutableCopy;
        }
    }
    return self;
}

- (NSMutableArray*)objectsOfClass:(Class)class fromArray:(NSArray*)array {
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dictionary in array) {
        id object = [[class alloc] initWithDictionary:dictionary];
        [mutableArray addObject:object];
    }
    return mutableArray;
}

- (Class)classForArrayObjectNamed:(NSString*)objectNamed {
    
    return [Color class];
}

#pragma mark - Getters and setters

- (void)setProductPhoto:(UIImage *)productPhoto {
    
    _productPhoto = productPhoto;
    
    [[MCSDataStore sharedInstance] updateProduct:self];
}

@end
