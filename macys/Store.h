//
//  Store.h
//  macys
//
//  Created by ws233 on 23.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "Entity.h"

@interface Store : Entity

@property (nonatomic, strong) NSNumber *storeId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *key;

@end
