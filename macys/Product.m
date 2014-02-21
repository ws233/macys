//
//  Product.m
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "Product.h"

#import <objc/runtime.h>

@interface Product ()
@property (nonatomic, strong) NSMutableDictionary *privateJsonData;
@end

@implementation Product

- (id)init {
    
    self = [self initWithDictionary:nil];
    if (self) {
        
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary {
    
    self = [super init];
    if (self) {
        self.id = dictionary[NSStringFromSelector(@selector(id))];
        self.name = dictionary[NSStringFromSelector(@selector(name))];
        self.description = dictionary[NSStringFromSelector(@selector(description))];
        self.regularPrice = dictionary[NSStringFromSelector(@selector(regularPrice))];
        self.salePrice = dictionary[NSStringFromSelector(@selector(salePrice))];
        self.productPhoto = dictionary[NSStringFromSelector(@selector(productPhoto))];
        self.colors = dictionary[NSStringFromSelector(@selector(colors))];
        self.stores = dictionary[NSStringFromSelector(@selector(stores))];
    }
    return self;
}

#pragma mark - Getters and setters

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

- (void)makeDictionaryFromProperties {
    
    NSDictionary *mappingDictionary = nil;
    
    Class class = self.class;
    while (class != Product.superclass) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(class, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
            if ([propertyName isEqualToString:NSStringFromSelector(@selector(jsonData))] ||
                [propertyName isEqualToString:NSStringFromSelector(@selector(privateJsonData))])
                continue;
            
            id propertyValue =  [self valueForKey:(NSString *)propertyName];
            
            //если в текущем подклассе определен словарь для меппинга, то начинаем проверять свойства на соответсвие JSON'у
            if(mappingDictionary) {
                //Если мы нашли замену propertyName на название параметра запроса, то меняем ключик
                NSString *jsonEquivalentName = mappingDictionary[propertyName];
                if (jsonEquivalentName)
                    propertyName = jsonEquivalentName;
            }
            
            if (propertyValue) {
                NSString *propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
                [self setValue:propertyValue forPropertyName:propertyName withAtributesString:propertyAttributes];
            }
        }
        free(properties);
        class = class.superclass;
    }
}

- (void)setValue:(id)value forPropertyName:(NSString*)name withAtributesString:(NSString*)propertyAttributes {
    
    unichar simb = [propertyAttributes characterAtIndex:1];
    NSCharacterSet *charecters = [NSCharacterSet characterSetWithCharactersInString:@"cCsSiIlLqQdfB"];
    if ([charecters characterIsMember:simb]) {
        
        // correct value, if it's NSNull
        if (value == [NSNull null])
            value = @(0);
        
        if (value && !([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSValue class]] || [value isKindOfClass:[NSString class]]) ) {
            NSLog(@"Incompatible class for property %@ in %@, NSNumber, NSValue or NSString are expected", name, self);
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
            [value isKindOfClass:[NSNull class]])
            [self.privateJsonData setObject:value forKey:name];
        else if ([value isKindOfClass:[NSArray class]])
            [self setArrayValue:value forPropertyName:name];
#if 0
        else if ([value isKindOfClass:[TFRequest class]]) {
            Product *request = (Product*)value;
            [self.privateJsonData setObject:request.dataDictionary forKey:name];
        }
#endif
        else
            NSAssert(0, @"Error! Object %@ is not serializable!", value);
    }
}

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
#if 0
            else if ([itemObject isKindOfClass:[TFRequest class]]) {
                TFRequest *request = (TFRequest*)itemObject;
                jsonObject = request.dataDictionary;
            }
#endif
            else if ([value isKindOfClass:[NSArray class]])
                NSAssert(0, @"Error! An array of array is not available in class: %@", self.class);
            else
                NSAssert(0, @"Error! Object %@ is not serializable!", value);
            
            [arrayOfObjects addObject:jsonObject];
        }
        [self.privateJsonData setValue:arrayOfObjects forKey:name];
    }
}

- (Class)classForArrayObjectNamed:(NSString*)objectNamed {
    
    return Nil;
}

@end
