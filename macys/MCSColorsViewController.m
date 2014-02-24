//
//  MCSColorsViewController.m
//  macys
//
//  Created by ws233 on 22.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "MCSColorsViewController.h"

#import "MCSDataStore.h"
#import "Color.h"

static NSString *CellIdentifier = @"ColorsCell";

@implementation MCSColorsViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Colors";
        self.allowsEditing = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self registerCell];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerCell {
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    // Configure the cell...
    Color *color = self.objects[indexPath.row];
    cell.textLabel.text = color.name;
    cell.textLabel.textColor = [UIColor colorFromRGB:color.rgb.integerValue];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if ([self.delegate respondsToSelector:@selector(objectsViewController:didRemoveObject:)]) {
            Entity *entity = self.objects[indexPath.row];
            [self.delegate objectsViewController:self didRemoveObject:entity];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - MCSObjectsViewController delegate methods

- (void)objectsViewController:(MCSColorsViewController *)controller didChooseObject:(Entity*)entity
{
    if ([self.delegate respondsToSelector:@selector(objectsViewController:didAddObject:)]) {
        [self.delegate objectsViewController:self didAddObject:entity];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.objects.count-1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Getters and setters

- (void)setAllowsEditing:(BOOL)allowsEditing
{
    _allowsEditing = allowsEditing;
    
    if (allowsEditing) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem, self.addButton];
    } else {
        self.navigationItem.leftBarButtonItem = self.cancelButton;
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }
}

- (UIBarButtonItem*)cancelButton
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
}

- (UIBarButtonItem*)saveButton
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped:)];
}

- (UIBarButtonItem*)addButton
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObjectTapped:)];
}

- (NSString*)reuseIdentifier {
    
    return CellIdentifier;
}

#pragma mark - Actions

- (void)insertNewObjectTapped:(id)sender
{
    NSMutableArray *mutableArray = [[MCSDataStore sharedInstance].allAvailableColors mutableCopy];
    for (Color *color in self.objects) {
        [mutableArray removeObject:color];
    }
    
    MCSColorsViewController *colorViewController = [[MCSColorsViewController alloc] init];
    colorViewController.objects = mutableArray;
    colorViewController.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:colorViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonTapped:(id)sender
{
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        Entity *selectedEntity = self.objects[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(objectsViewController:didChooseObject:)]) {
            [self.delegate objectsViewController:self didChooseObject:selectedEntity];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
