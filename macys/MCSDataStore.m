//
//  MCSDataStore.m
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "MCSDataStore.h"

#import "FMDatabase.h"
#import "Color.h"
#import "Product.h"
#import "Store.h"
#import "Base64.h"

NSString *const kDataStoreDidLoadDataFromJSONNotification = @"kDataStoreDidLoadDataFromJSONNotification";

@interface MCSDataStore ()
@property (nonatomic, readonly) NSMutableArray *mutableArrayOfProducts;
@property (nonatomic, readonly) NSString *documentsDirectory;
@property (nonatomic, readonly) NSString *databasePath;
@property (nonatomic, readonly) FMDatabase *database;
@end

@implementation MCSDataStore

+ (instancetype)sharedInstance {
    
    static MCSDataStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self openDatabase];
    }
    return self;
}

- (int)openDatabase {
    
    // delete the old db.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:self.databasePath]) {
        // first start
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
        
        [self.database executeUpdate:@"create table stores (id integer PRIMARY KEY, name text, key text)"];
        [self.database executeUpdate:@"create table productsToStores (product integer, store integer)"];
        
        [self.database executeUpdate:@"insert into stores (name, key) values (?, ?)", @"Store 1", @"st1"];
        [self.database executeUpdate:@"insert into stores (name, key) values (?, ?)", @"Small Store", @"sm"];
        [self.database executeUpdate:@"insert into stores (name, key) values (?, ?)", @"Large Store", @"lg"];
        [self.database executeUpdate:@"insert into stores (name, key) values (?, ?)", @"Huge Store", @"hg"];
        [self.database executeUpdate:@"insert into stores (name, key) values (?, ?)", @"Store 2", @"st2"];
        [self.database executeUpdate:@"insert into stores (name, key) values (?, ?)", @"Store 3", @"st3"];
        
        // perform selector after delay to avoid dead lock during very first initialization
        // not a good idea, but very fast! ^^
#if 1
        [self performSelector:@selector(saveProductsFromJSONToDataBase) withObject:nil afterDelay:0.01];
#else
        [self saveProductsFromJSONToDataBase];
#endif
    }
    
    return 0;
}

- (void)saveProductsFromJSONToDataBase {
    
    [self.mutableArrayOfProducts addObjectsFromArray:[self productsFromJSON]];
    for (Product *product in self.products) {
        [self saveProductToDataBase:product];
        for (Store *store in product.stores) {
            [self saveStore:store toProduct:product];
        }
        for (Color *color in product.colors) {
            [self saveColor:color toProduct:product];
        }
    }
    
    // update IU after data processed
    [[NSNotificationCenter defaultCenter] postNotificationName:kDataStoreDidLoadDataFromJSONNotification object:self];
}

- (void)addProduct:(Product*)product {
    
    if (![self.products containsObject:product]) {
        [self saveProductToDataBase:product];
        [self.mutableArrayOfProducts addObject:product];
    }
}

- (void)saveProductToDataBase:(Product*)product {
    
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
    
    //[self saveToJSONFile];
}

- (void)removeProduct:(Product*)product {
    
    [self.database beginTransaction];
    [self.database executeUpdate:@"delete from products where id = ?", product.productId];
    // delete dependencies
    [self.database executeUpdate:@"delete from productsToColors where product = ?", product.productId];
    [self.database executeUpdate:@"delete from productsToStores where product = ?", product.productId];
    [self.database commit];
    
    [self.mutableArrayOfProducts removeObject:product];
}

- (void)addColor:(Color*)color toProduct:(Product*)product
{
    if (![product.colors containsObject:color]) {
        [product.colors addObject:color];
        [self saveColor:color toProduct:product];
    }
}

- (void)saveColor:(Color*)color toProduct:(Product*)product
{
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
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM productsToColors WHERE product = %lu", (unsigned long)productId];
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

- (void)addStore:(Store*)store toProduct:(Product*)product {
    
    if (![product.stores containsObject:store]) {
        [product.stores addObject:store];
        [self saveStore:store toProduct:product];
    }
}

- (void)saveStore:(Store*)store toProduct:(Product*)product {
    
    [self.database beginTransaction];
    [self.database executeUpdate:@"insert into productsToStores (product, store) values (?, ?)", product.productId, store.storeId];
    [self.database commit];
}

- (void)removeStore:(Store*)store fromProduct:(Product*)product {
    
    [product.stores removeObject:store];
    [self.database beginTransaction];
    [self.database executeUpdate:@"delete from productsToStores where product = ? and store = ?", product.productId, store.storeId];
    [self.database commit];
}

- (NSSet*)storesForProductId:(NSUInteger)productId {
    
    NSMutableSet *set = [NSMutableSet set];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM productsToStores WHERE product = %lu", (unsigned long)productId];
    FMResultSet *resultSet = [self.database executeQuery:query];
    
    while ([resultSet next]) {
        NSNumber *storeId = resultSet.resultDictionary[@"store"];
        NSInteger index = [self.allAvailableStores indexOfObjectPassingTest:^BOOL(Store *store, NSUInteger idx, BOOL *stop) {
            return store.storeId.integerValue == storeId.integerValue;
        }];
        if (index != NSNotFound) {
            Store *store = self.allAvailableStores[index];
            [set addObject:store];
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
        if (!jsonData) {
            DLog(@"error");
        }
        else {
            [jsonData writeToFile:self.jsonFileName atomically:YES];
        }
    } else {
        DLog(@"Not valid JSON object!");
    }
}

- (NSMutableArray*)productsFromJSON {
    
    NSData *data = [NSData dataWithContentsOfFile:self.jsonFileName];
    NSError *error = nil;
    NSArray *productsDictionaryArray = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error] : nil;
    
    if ([productsDictionaryArray isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:productsDictionaryArray.count];
        
        for (NSDictionary *dictionary in productsDictionaryArray) {
            
            Product *product = [[Product alloc] initWithDictionary:dictionary];
            [mutableArray addObject:product];
        }
        
        return mutableArray;
        
    }
    else {
        DLog(@"%@", error);
    }
    return nil;
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
    
    //return [self.documentsDirectory stringByAppendingPathComponent:@"first.json"];
    return [[NSBundle mainBundle] pathForResource:@"first" ofType:@"json"];
}

- (NSString *)databasePath {
    
    return [self.documentsDirectory stringByAppendingPathComponent:@"database.sqlite"];
}

- (FMDatabase*)database {
    
    static FMDatabase *database = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //NSFileManager *fileManager = [NSFileManager defaultManager];
        //[fileManager removeItemAtPath:dbPath error:nil];
        
        database = [FMDatabase databaseWithPath:self.databasePath];
        
        DLog(@"Is SQLite compiled with it's thread safe options turned on? %@!", [FMDatabase isSQLiteThreadSafe] ? @"Yes" : @"No");
        
        if (![database open]) {
            DLog(@"Could not open db.");
            DLog(@"%d: %@", self.database.lastErrorCode, database.lastErrorMessage);
        }
    });
    return database;
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
    
    static NSMutableArray *mutableArrayOfProducts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mutableArrayOfProducts = self.allProductFromDataBase;
    });
    return mutableArrayOfProducts;
}
     
- (NSArray *)products {
    
    // return immitable copy to avoid others to change an array
    return [self.mutableArrayOfProducts copy];
}

- (NSArray *)allAvailableColors {
    
    static NSArray *allAvailableColors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FMResultSet *resultSet = [self.database executeQuery:@"select * from colors"];
        NSMutableArray *mutableArray = [NSMutableArray array];
        while ([resultSet next]) {
            
            Color *color = [[Color alloc] initWithDictionary:resultSet.resultDictionary];
            [mutableArray addObject:color];
        }
        allAvailableColors = mutableArray;
    });
    return allAvailableColors;
}

- (NSArray *)allAvailableStores {
    
    static NSArray *allAvailableStores = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FMResultSet *resultSet = [self.database executeQuery:@"select * from stores"];
        NSMutableArray *mutableArray = [NSMutableArray array];
        while ([resultSet next]) {
            
            Store *store = [[Store alloc] initWithDictionary:resultSet.resultDictionary];
            [mutableArray addObject:store];
        }
        allAvailableStores = mutableArray;
    });
    return allAvailableStores;
}

@end
