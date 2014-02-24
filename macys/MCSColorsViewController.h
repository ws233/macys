//
//  MCSColorsViewController.h
//  macys
//
//  Created by ws233 on 22.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Entity;
@class MCSColorsViewController;

@protocol MCSObjectsViewControllerDelegate <NSObject>

@optional
- (void)objectsViewController:(MCSColorsViewController*)controller didChooseObject:(Entity*)object;
- (void)objectsViewController:(MCSColorsViewController*)controller didAddObject:(Entity*)object;
- (void)objectsViewController:(MCSColorsViewController*)controller didRemoveObject:(Entity*)object;

@end

@interface MCSColorsViewController : UITableViewController <MCSObjectsViewControllerDelegate>

/**
  An array of entities being shown in MCSColorsViewController view
 */
@property (nonatomic) NSMutableArray *objects;

/**
  if YES, 'Edit' and 'Add' buttons appears in the navigation bar,
  allowing the MCSColorsViewController to edit the content (an objects array)
 */
@property (nonatomic) BOOL allowsEditing;

/**
  MCSColorsViewController delegate
  */
@property (nonatomic, weak) id<MCSObjectsViewControllerDelegate> delegate;

@end

