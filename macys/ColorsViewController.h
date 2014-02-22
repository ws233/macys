//
//  ColorsViewController.h
//  macys
//
//  Created by ws233 on 22.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Color;
@class ColorsViewController;

@protocol ColorsViewControllerDelegate <NSObject>

@optional
- (void)colorsViewController:(ColorsViewController*)controller didChooseColor:(Color*)color;
- (void)colorsViewController:(ColorsViewController*)controller didAddColor:(Color*)color;
- (void)colorsViewController:(ColorsViewController*)controller didRemoveColor:(Color*)color;

@end

@interface ColorsViewController : UITableViewController <ColorsViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *colors;

@property (nonatomic) BOOL allowsEditing;

@property (nonatomic, weak) id<ColorsViewControllerDelegate> delegate;

@end

