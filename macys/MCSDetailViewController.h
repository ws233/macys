//
//  MCSDetailViewController.h
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCSColorsViewController.h"

@class Product;

@interface MCSDetailViewController : UIViewController <
    UIScrollViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIActionSheetDelegate,
    MCSObjectsViewControllerDelegate
>

/**
  A Product entity object being shown in MCSDetailViewController view
 */
@property (nonatomic) Product *detailItem;

@end
