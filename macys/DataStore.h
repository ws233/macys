//
//  DataStore.h
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"
#import "Color.h"

@interface DataStore : NSObject

@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong, readonly) NSArray *allAvailableColors;

+ (instancetype)sharedInstance;

- (id)init __attribute__((unavailable("init is not available, use class methods 'sharedInstance' instead!")));
- (id)copy __attribute__((unavailable("copy is not available, use class methods 'sharedInstance' instead!")));

- (void)addProduct:(Product*)product;
- (void)removeProduct:(Product*)product;
- (void)updateProduct:(Product*)product;

- (void)addColor:(Color*)color toProduct:(Product*)product;
- (void)removeColor:(Color*)color fromProduct:(Product*)product;
- (NSSet*)colorsForProductId:(NSUInteger)productId;

@end
