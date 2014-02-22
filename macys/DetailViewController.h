//
//  DetailViewController.h
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ColorsViewController.h"

@class Product;

@interface DetailViewController : UIViewController <UIScrollViewDelegate, ColorsViewControllerDelegate>

@property (strong, nonatomic) Product *detailItem;

@end
