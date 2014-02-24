//
//  Entity.m
//  macys
//
//  Created by ws233 on 22.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "Entity.h"

#import <objc/runtime.h>
#import "Base64.h"

@interface Entity ()
@property (nonatomic) NSMutableDictionary *privateJsonData;
@end

@implementation Entity

#pragma mark - Getters and setters

- (instancetype)init {
    
    self = [self initWithDictionary:nil];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {

    }
    return self;
}

- (id)valueForKey:(NSString *)key fromDictionary:(NSDictionary*)dictionary {
    
    id value = dictionary[key];
    if ([value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    else {
        return value;
    }
}

- (NSMutableDictionary *)jsonData {
    
    // the getter is not pretty good,
    // cause the function to serrialize objects to json
    // (makeDictionaryFromProperties, setValue:forPropertyName:withAtributesString:, setArrayValue:forPropertyName:)
    // were copied from other project as is due to the lack of time
    // that's why we have to create a property privateJsonData first,
    // the property will contain json dictionary after makeDictionaryFromProperties function finishes
    // than we store the result to a temp variable, clear the property and return the result from temp variable
    // otherwise we cannot cleare privateJsonData property and lead a memory waisting
    self.privateJsonData = [NSMutableDictionary dictionary];
    
    [self makeDictionaryFromProperties];
    
    NSMutableDictionary *tempDict = self.privateJsonData;
    
    self.privateJsonData = nil;
    
    return tempDict;
}

#pragma mark - Functions to save data to JSON

/*
 Recursively goes through all the properties of all the superclasses till Entity
 to make a dictionary of keys equals to property names and values equals to property values.
 Used to make a proper JSON object from Entity, so this object can be serialized to JSON and be saved to file.
 */
- (void)makeDictionaryFromProperties {
    
    Class class = self.class;
    while (class != Entity.class) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(class, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
            
            id propertyValue =  [self valueForKey:(NSString *)propertyName];
            if (propertyValue) {
                NSString *propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
                [self setValue:propertyValue forPropertyName:propertyName withAtributesString:propertyAttributes];
            }
        }
        free(properties);
        class = class.superclass;
    }
}

/*
 Checks the type of the property an set the correct object to JSON dictionary
 */
- (void)setValue:(id)value forPropertyName:(NSString*)name withAtributesString:(NSString*)propertyAttributes {
    
    unichar simb = [propertyAttributes characterAtIndex:1];
    NSCharacterSet *charecters = [NSCharacterSet characterSetWithCharactersInString:@"cCsSiIlLqQdfB"];
    if ([charecters characterIsMember:simb]) {
        
        // correct value, if it's NSNull
        if (value == [NSNull null]) {
            value = @(0);
        }
        
        if (value && !([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSValue class]] || [value isKindOfClass:[NSString class]]) ) {
            DLog(@"Incompatible class for property %@ in %@, NSNumber, NSValue or NSString are expected", name, self);
#if DEBUG
            assert(0);
#endif
            return;
        }
        
        // set value
        [self.privateJsonData setValue:value forKey:name];
    }
    else if (simb == '@') { //objects
        if ([value isKindOfClass:[NSString class]] ||
            [value isKindOfClass:[NSNumber class]] ||
            [value isKindOfClass:[NSDictionary class]] ||
            [value isKindOfClass:[NSNull class]]) {
            [self.privateJsonData setObject:value forKey:name];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            [self setArrayValue:value forPropertyName:name];
#if 0
        }
        else if ([value isKindOfClass:[TFRequest class]]) {
            Product *request = (Product*)value;
            [self.privateJsonData setObject:request.dataDictionary forKey:name];
        }
#endif
        }
        else if ([value isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage*)value;
            [self.privateJsonData setObject:[UIImagePNGRepresentation(image) base64EncodedString] forKey:name];
        }
        else {
            NSAssert(0, @"Error! Object %@ is not serializable!", value);
        }
    }
}

/*
 if the property type is NSArray, this function is called to make a json objects from every Entity in the Array.
 */
- (void)setArrayValue:(NSArray *)value forPropertyName:(NSString *)name {
    
    Class itemClass = [self classForArrayObjectNamed:name];
    if ([itemClass isSubclassOfClass:[NSDictionary class]]) {
        [self.privateJsonData setValue:value forKey:name];
    } else {
        NSArray *array = value;
        NSMutableArray *arrayOfObjects = [NSMutableArray arrayWithCapacity:array.count];
        for (id itemObject in array) {
            id jsonObject = nil;
            if ([itemObject isKindOfClass:[NSString class]] ||
                [itemObject isKindOfClass:[NSNumber class]] ||
                [itemObject isKindOfClass:[NSDictionary class]] ||
                [itemObject isKindOfClass:[NSNull class]]) {
                jsonObject = itemObject;
            }
            else if ([itemObject isKindOfClass:[Entity class]]) {
                Entity *request = (Entity*)itemObject;
                jsonObject = request.jsonData;
            }
            else if ([value isKindOfClass:[NSArray class]]) {
                NSAssert(0, @"Error! An array of array is not available in class: %@", self.class);
            }
            else {
                NSAssert(0, @"Error! Object %@ is not serializable!", value);
            }
            
            [arrayOfObjects addObject:jsonObject];
        }
        [self.privateJsonData setValue:arrayOfObjects forKey:name];
    }
}

- (Class)classForArrayObjectNamed:(NSString*)objectNamed {
    
    return Nil;
}

@end

