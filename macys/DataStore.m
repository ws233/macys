//
//  DataStore.m
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "DataStore.h"

#import "FMDatabase.h"
#import "Color.h"
#import "Base64.h"

#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }

@interface DataStore ()
@property (nonatomic, strong) NSMutableArray *mutableArrayOfProducts;
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong, readwrite) NSArray *allAvailableColors;
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
        // first start
        self.products = [self productsFromJSON];
        
        [self createDataBaseAtPath:dbPath];
        
        [self.database executeUpdate:@"create table products (id integer PRIMARY KEY, name text, description text, regularPrice double, salePrice double, productPhoto text)"]; // colors, stores )"];
        [self.database executeUpdate:@"create table colors (id integer PRIMARY KEY, name text, rgb integer)"];
        [self.database executeUpdate:@"create table productsToColors (product integer, color integer)"];
        
        [self.database executeUpdate:@"insert into colors (name, rgb) values (?, ?)", @"red", @([UIColor redColor].colorCode)];
        [self.database executeUpdate:@"insert into colors (name, rgb) values (?, ?)", @"green", @([UIColor greenColor].colorCode)];
        [self.database executeUpdate:@"insert into colors (name, rgb) values (?, ?)", @"blue", @([UIColor blueColor].colorCode)];
        [self.database executeUpdate:@"insert into colors (name, rgb) values (?, ?)", @"magenta", @([UIColor magentaColor].colorCode)];
        [self.database executeUpdate:@"insert into colors (name, rgb) values (?, ?)", @"yellow", @([UIColor yellowColor].colorCode)];
        [self.database executeUpdate:@"insert into colors (name, rgb) values (?, ?)", @"orange", @([UIColor orangeColor].colorCode)];
        [self.database executeUpdate:@"insert into colors (name, rgb) values (?, ?)", @"black", @([UIColor blackColor].colorCode)];
        [self.database executeUpdate:@"insert into colors (name, rgb) values (?, ?)", @"gray", @([UIColor lightGrayColor].colorCode)];
        
    } else {
        
        [self createDataBaseAtPath:dbPath];
    }
    
    return 0;
}

- (NSInteger)createDataBaseAtPath:(NSString*)dbPath {
    
    //[fileManager removeItemAtPath:dbPath error:nil];
    
    self.database = [FMDatabase databaseWithPath:dbPath];
    
    NSLog(@"Is SQLite compiled with it's thread safe options turned on? %@!", [FMDatabase isSQLiteThreadSafe] ? @"Yes" : @"No");
    
    if (![self.database open]) {
        NSLog(@"Could not open db.");
        NSLog(@"%d: %@", self.database.lastErrorCode, self.database.lastErrorMessage);
        return self.database.lastErrorCode;
    }
    
    return 0;
}

- (void)addProduct:(Product*)product {
    
    [self.database beginTransaction];
    
    [self.database executeUpdate:@"insert into products (id, productPhoto, name, description, regularPrice, salePrice) values (?, ?, ?, ?, ?, ?)" ,
     product.productId,
     [UIImagePNGRepresentation(product.productPhoto) base64EncodedString],
     product.name,
     product.explonation,
     product.regularPrice,
     product.salePrice];
    
    [self.database commit];
    
    product.productId = self.productIdLastInserted;
    [self.mutableArrayOfProducts addObject:product];
}

- (void)updateProduct:(Product*)product {
    
    [self.database beginTransaction];
    
    [self.database executeUpdate:@"update products set productPhoto = ?, name = ?, description = ?, regularPrice = ?, salePrice = ? where id = ?" ,
     [UIImagePNGRepresentation(product.productPhoto) base64EncodedString],
     product.name,
     product.explonation,
     product.regularPrice,
     product.salePrice,
     product.productId
     ];
    
    [self.database commit];
    
    [self saveToJSONFile];
}

- (void)removeProduct:(Product*)product {
    
    [self.database beginTransaction];
    
    [self.database executeUpdate:@"delete from products where id = ?", product.productId];
    
    [self.database commit];
    
    [self.mutableArrayOfProducts removeObject:product];
}

- (void)addColor:(Color*)color toProduct:(Product*)product
{
    [product.colors addObject:color];
    
    [self.database beginTransaction];
    
    [self.database executeUpdate:@"insert into productsToColors (product, color) values (?, ?)", product.productId, color.colorId];
    
    [self.database commit];
}

- (void)removeColor:(Color*)color fromProduct:(Product*)product
{
    [product.colors removeObject:color];

    [self.database beginTransaction];
    
    [self.database executeUpdate:@"delete from productsToColors where product = ? and color = ?", product.productId, color.colorId];
    
    [self.database commit];
}

- (NSSet*)productsWithId:(NSNumber*)productId {
    
    NSMutableSet *set = [NSMutableSet set];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM products WHERE id = %@", productId];
    FMResultSet *resultSet = [self.database executeQuery:query];
    
    while ([resultSet next]) {
        Product *product = [[Product alloc] initWithDictionary:resultSet.resultDictionary];
        [set addObject:product];
    }
    
    return set;
}

- (NSSet*)colorsForProductId:(NSUInteger)productId {
    
    NSMutableSet *set = [NSMutableSet set];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM productsToColors WHERE product = %d", productId];
    FMResultSet *resultSet = [self.database executeQuery:query];
    
    while ([resultSet next]) {
        NSNumber *colorId = resultSet.resultDictionary[@"color"];
        NSInteger index = [self.allAvailableColors indexOfObjectPassingTest:^BOOL(Color *color, NSUInteger idx, BOOL *stop) {
            return color.colorId.integerValue == colorId.integerValue;
        }];
        if (index != NSNotFound) {
            Color *color = self.allAvailableColors[index];
            [set addObject:color];
        }
    }
    
    return set;
}

- (NSNumber*)productIdLastInserted {
    
    NSString *query = [NSString stringWithFormat:@"SELECT last_insert_rowid() FROM products"];
    FMResultSet *resultSet = [self.database executeQuery:query];
    
    [resultSet next];
    NSDictionary *dictionary = resultSet.resultDictionary;

    return dictionary[@"last_insert_rowid()"];
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

- (NSArray *)allAvailableColors {
    
    if (!_allAvailableColors) {
        FMResultSet *resultSet = [self.database executeQuery:@"select * from colors"];
        NSMutableArray *mutableArray = [NSMutableArray array];
        while ([resultSet next]) {
            
            Color *color = [[Color alloc] initWithDictionary:resultSet.resultDictionary];
            [mutableArray addObject:color];
        }
        _allAvailableColors = mutableArray;
    }
    return _allAvailableColors;
}

@end
