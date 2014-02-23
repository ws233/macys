//
//  StoresViewController.m
//  macys
//
//  Created by ws233 on 23.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "StoresViewController.h"
#import "DataStore.h"
#import "Store.h"

static NSString *const StoreTableViewCellReuseIdentifier = @"StoreTableViewCellReuseIdentifier";

@interface StoresViewController ()

@end

@implementation StoresViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Stores";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerCell {
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StoreTableViewCell" bundle:nil] forCellReuseIdentifier:self.reuseIdentifier];
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    // Configure the cell...
    Store *store = self.objects[indexPath.row];
    cell.textLabel.text = store.key;
    cell.detailTextLabel.text = store.name;
}

- (void)insertNewObjectTapped:(id)sender
{
    NSMutableArray *mutableArray = [[DataStore sharedInstance].allAvailableStores mutableCopy];
    for (Color *color in self.objects) {
        [mutableArray removeObject:color];
    }
    
    StoresViewController *storesViewController = [[StoresViewController alloc] init];
    storesViewController.objects = mutableArray;
    storesViewController.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:storesViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (NSString*)reuseIdentifier {
    
    return StoreTableViewCellReuseIdentifier;
}

@end
