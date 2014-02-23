//
//  DataStore.h
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class Product;
@class Color;
@class Store;

extern NSString *const kDataStoreDidLoadDataFromJSONNotification;

@interface DataStore : NSObject

@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong, readonly) NSArray *allAvailableColors;
@property (nonatomic, strong, readonly) NSArray *allAvailableStores;

@property (nonatomic, readonly) FMDatabase *database;

+ (instancetype)sharedInstance;

- (id)init __attribute__((unavailable("init is not available, use class methods 'sharedInstance' instead!")));
- (id)copy __attribute__((unavailable("copy is not available, use class methods 'sharedInstance' instead!")));

- (void)addProduct:(Product*)product;
- (void)removeProduct:(Product*)product;
- (void)updateProduct:(Product*)product;

- (void)addColor:(Color*)color toProduct:(Product*)product;
- (void)removeColor:(Color*)color fromProduct:(Product*)product;
- (NSSet*)colorsForProductId:(NSUInteger)productId;

- (void)addStore:(Store*)color toProduct:(Product*)product;
- (void)removeStore:(Store*)color fromProduct:(Product*)product;
- (NSSet*)storesForProductId:(NSUInteger)productId;

@end
