//
//  MCSDataStore.h
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

@interface MCSDataStore : NSObject

/**
 products table
 */
@property (nonatomic, readonly) NSArray *products;

/** 
 colors table
 */
@property (nonatomic, readonly) NSArray *allAvailableColors;

/**
 stores table
 */
@property (nonatomic, readonly) NSArray *allAvailableStores;

/**
 @returns a singleton instance of MCSDataStore
 */
+ (instancetype)sharedInstance;

/**
 MCSDataStore is a singleton, that's why 'init' is unavailable
 */
- (id)init __attribute__((unavailable("init is not available, use class methods 'sharedInstance' instead!")));

/**
 MCSDataStore is a singleton, that's why 'copy' is unavailable
 */
- (id)copy __attribute__((unavailable("copy is not available, use class methods 'sharedInstance' instead!")));

/**
 adds product to database
 @param product Product entity being inserted into database
 */
- (void)addProduct:(Product*)product;

/**
  removes the Product entity from the database
  @param product Product entity being removed from database
 */
- (void)removeProduct:(Product*)product;

/**
  saves the Product entity modified during application run to the database. After operation completes, the entity in the database completely the same as in memory. The function should be called after any changes of the Product entity has been occured
  @param product Product entity being saved to database
 */
- (void)updateProduct:(Product*)product;

/**
  adds Color entity to the Product entity.
  @param color Color entity being added to Product entity
  @param product Product entity being linked with Color entity
 */
- (void)addColor:(Color*)color toProduct:(Product*)product;

/**
  removes Color entity from the Product entity.
  @param color Color entity being removed from the Product entity
  @param product Product entity, from which the Color entity being removed
 */
- (void)removeColor:(Color*)color fromProduct:(Product*)product;

/**
  Search for all Color entities for the Product entity with the given id
  @param productId An id of the Product entity being search for
  @returns A set of the Color entities for the project with the given id
 */
- (NSSet*)colorsForProductId:(NSUInteger)productId;

/**
 adds Store entity to the Product entity.
 @param store Store entity being added to Product entity
 @param product Product entity being linked with Store entity
 */
- (void)addStore:(Store*)store toProduct:(Product*)product;

/**
 removes Store entity from the Product entity.
 @param color Color entity being removed from the Product entity
 @param product Product entity, from which the Color entity being removed
 */
- (void)removeStore:(Store*)store fromProduct:(Product*)product;

/**
 Search for all Store entities for the Product entity with the given id
 @param productId An id of the Product entity being search for
 @returns A set of the Store entities for the project with the given id
 */
- (NSSet*)storesForProductId:(NSUInteger)productId;

@end
