//
//  DetailViewController.m
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (nonatomic, strong) IBOutlet UILabel *textFieldName;
@property (nonatomic, strong) IBOutlet UILabel *textViewDescription;
@property (nonatomic, strong) IBOutlet UITextField *textFieldRegularPrice;
@property (nonatomic, strong) IBOutlet UITextField *textFieldSalePrice;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewProductPhoto;
//@property (nonatomic, strong) IBOutlet NSArray *colors;
//@property (nonatomic, strong) IBOutlet NSDictionary *stores;
@property (nonatomic, strong) IBOutlet UILabel *labelName;
@property (nonatomic, strong) IBOutlet UILabel *labelDescription;
@property (nonatomic, strong) IBOutlet UILabel *labelRegularPrice;
@property (nonatomic, strong) IBOutlet UILabel *labelSalePrice;
//@property (nonatomic, strong) IBOutlet NSArray *colors;
//@property (nonatomic, strong) IBOutlet NSDictionary *stores;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Product";
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    return self;
}

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)buttonDoneTapped:(id)sender {
    
    [self setEditing:YES animated:YES];
}

@end
