//
//  Entity.h
//  macys
//
//  Created by ws233 on 22.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Entity : NSObject

@property (nonatomic, strong) NSMutableDictionary *jsonData;

- (id)initWithDictionary:(NSDictionary*)dictionary; // designed

@end
