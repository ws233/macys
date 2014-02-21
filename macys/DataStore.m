//
//  DataStore.m
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "DataStore.h"

#import "FMDatabase.h"

#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }

@interface DataStore ()
@property (nonatomic, strong) NSMutableArray *mutableArrayOfProducts;
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *documentsDirectory;
@end

@implementation DataStore

+ (instancetype)sharedInstance {
    
    static DataStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    
    self = [super init];
    if (self) {
        [self openDatabase];
    }
    return self;
}

- (int)openDatabase {
    
    NSString *dbPath = [self.documentsDirectory stringByAppendingPathComponent:@"database.sqlite"];
    
    // delete the old db.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:dbPath]) {
        
        self.products = [self productsFromJSON];
    }
    
    //[fileManager removeItemAtPath:dbPath error:nil];
    
    self.database = [FMDatabase databaseWithPath:dbPath];
    
    NSLog(@"Is SQLite compiled with it's thread safe options turned on? %@!", [FMDatabase isSQLiteThreadSafe] ? @"Yes" : @"No");
    
    if (![self.database open]) {
        NSLog(@"Could not open db.");
        NSLog(@"%d: %@", self.database.lastErrorCode, self.database.lastErrorMessage);
        return self.database.lastErrorCode;
    }
    
    [self.database executeUpdate:@"create table products (id integer, name text, description text, regularPrice double, salePrice double)"]; //, productPhoto, colors, stores )"];
    
    return 0;
}

- (void)addProduct:(Product*)product {
    
    [self.database beginTransaction];
    
    [self.database executeUpdate:@"insert into products (id, name, description, regularPrice, salePrice) values (?, ?, ?, ?, ?)" ,
     product.id,
     product.name,
     product.description,
     product.regularPrice,
     product.salePrice];
    
    [self.database commit];
    
    [self.mutableArrayOfProducts addObject:product];
    
    [self saveToJSONFile];
}

- (void)removeProduct:(Product*)product {
    
    [self.database beginTransaction];
    
    BOOL res = [self.database executeUpdate:@"delete from products where id = ?", product.id];
    
    [self.database commit];
    
    [self.mutableArrayOfProducts removeObject:product];
}

#pragma mark - JSON related functions

- (void)saveToJSONFile {
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:self.mutableArrayOfProducts.count];
    for (Product *product in self.products) {
        [mutableArray addObject:product.jsonData];
    }
    
    if ([NSJSONSerialization isValidJSONObject:mutableArray]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableArray options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            NSLog(@"error");
        } else {
            [jsonData writeToFile:self.jsonFileName atomically:YES];
        }
    } else {
        NSLog(@"Not valid JSON object!");
    }
    
}

- (NSMutableArray*)productsFromJSON {
    
    NSData *data = [NSData dataWithContentsOfFile:self.jsonFileName];
    NSError *error = nil;
    id products = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error] : nil;
    if (error) {
        NSLog(@"%@", error);
    }
    return [products isKindOfClass:[NSMutableArray class]] ? products : nil;
}

#pragma mark - Getters and setters

- (NSString *)documentsDirectory {
    
    static NSString *documentsDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    });
    return documentsDirectory;
}

- (NSString*)jsonFileName {
    
    return [self.documentsDirectory stringByAppendingPathComponent:@"first.json"];
}

- (NSMutableArray*)allProductFromDataBase {
    
    FMResultSet *resultSet = [self.database executeQuery:@"select * from products"];
    NSMutableArray *mutableArray = [NSMutableArray array];
    while ([resultSet next]) {
        
        Product *product = [[Product alloc] initWithDictionary:resultSet.resultDictionary];
        [mutableArray addObject:product];
    }
    return mutableArray;
}

- (NSMutableArray *)mutableArrayOfProducts {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mutableArrayOfProducts = self.allProductFromDataBase;
    });
    return _mutableArrayOfProducts;
}
     
- (NSArray *)products {
    
    // return immitable copy to avoid others to change an array
    return [self.mutableArrayOfProducts copy];
}

@end
