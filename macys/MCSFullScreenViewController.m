//
//  MCSFullScreenViewController.m
//  macys
//
//  Created by ws233 on 22.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "MCSFullScreenViewController.h"

@interface MCSFullScreenViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end

@implementation MCSFullScreenViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Product Preview";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.imageView.image = self.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
