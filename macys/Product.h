//
//  Product.h
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (nonatomic, strong) NSNumber *productId;  // the same as id, prefer not to use it, since it's a objc keyword
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *explonation; // the same as 'description'. not available, cause it's already defined in NSObject
@property (nonatomic, strong) NSNumber *regularPrice;
@property (nonatomic, strong) NSNumber *salePrice;
@property (nonatomic, strong) UIImage *productPhoto;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSDictionary *stores;

- (id)initWithDictionary:(NSDictionary*)dictionary; // designed

@property (nonatomic, strong) NSMutableDictionary *jsonData;


@end
