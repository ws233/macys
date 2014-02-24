//
//  Entity.h
//  macys
//
//  Created by ws233 on 22.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Entity : NSObject

@property (nonatomic) NSMutableDictionary *jsonData;

/**
  Designed initializer.
  @param dictionary A dictionary with keys, which should be equal to Entity properties' names and corresponding values being set to those properties.
  @returns a newly created instance of Entity, with the properties initialized from dictionary
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary; // designed

/**
  Validates a value for the 'key' from the 'dictionary' and return a correct value, if possible. For example, if there is an NSNull instance, this functions returns nil, instead of that instance to avoid crushes on the unrecognized selector being send to NSNull.
  @param key a key to search for the value in the 'dictionary'
  @param dictionary a dictioanry of the keys and values
  @returns nil, if the value for key is NSNull instance, and just the value otherwise
 */
- (id)valueForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary;

@end
