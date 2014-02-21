//
//  DataStore.h
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface DataStore : NSObject

@property (nonatomic, strong) NSArray *products;

+ (instancetype)sharedInstance;

- (id)init __attribute__((unavailable("init is not available, use class methods 'sharedInstance' instead!")));
- (id)copy __attribute__((unavailable("copy is not available, use class methods 'sharedInstance' instead!")));

- (void)addProduct:(Product*)product;
- (void)removeProduct:(Product*)product;

@end
