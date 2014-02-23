//
//  ColorsViewController.h
//  macys
//
//  Created by ws233 on 22.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Entity;
@class ColorsViewController;

@protocol ObjectsViewControllerDelegate <NSObject>

@optional
- (void)objectsViewController:(ColorsViewController*)controller didChooseObject:(Entity*)object;
- (void)objectsViewController:(ColorsViewController*)controller didAddObject:(Entity*)object;
- (void)objectsViewController:(ColorsViewController*)controller didRemoveObject:(Entity*)object;

@end

@interface ColorsViewController : UITableViewController <ObjectsViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *objects;

@property (nonatomic) BOOL allowsEditing;

@property (nonatomic, weak) id<ObjectsViewControllerDelegate> delegate;

@end

