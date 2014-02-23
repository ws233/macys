//
//  DetailViewController.m
//  macys
//
//  Created by Cyril iOS on 21.02.14.
//  Copyright (c) 2014 macys. All rights reserved.
//

#import "DetailViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "FullScreenViewController.h"
#import "StoresViewController.h"

#import "DataStore.h"
#import "Product.h"
#import "Color.h"
#import "Store.h"

@interface DetailViewController ()
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UITextField *textFieldName;
@property (nonatomic, weak) IBOutlet UITextView *textViewDescription;
@property (nonatomic, weak) IBOutlet UITextField *textFieldRegularPrice;
@property (nonatomic, weak) IBOutlet UITextField *textFieldSalePrice;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProductPhoto;
@property (nonatomic, weak) IBOutlet UIButton *buttonColors;
@property (nonatomic, weak) IBOutlet UIButton *buttonStores;
@property (nonatomic, weak) IBOutlet UILabel *labelName;
@property (nonatomic, weak) IBOutlet UILabel *labelDescription;
@property (nonatomic, weak) IBOutlet UILabel *labelRegularPrice;
@property (nonatomic, weak) IBOutlet UILabel *labelSalePrice;
@property (nonatomic, weak) IBOutlet UIButton *buttonImage;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Product";
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
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
    if (self.detailItem && self.isViewLoaded) {
        self.imageViewProductPhoto.image = self.detailItem.productPhoto;
        self.labelName.text = self.textFieldName.text = self.detailItem.name;
        self.labelDescription.text = self.textViewDescription.text = self.detailItem.explonation;
        self.labelRegularPrice.text = self.textFieldRegularPrice.text = [NSNumberFormatter localizedStringFromNumber:self.detailItem.regularPrice numberStyle:NSNumberFormatterDecimalStyle];
        self.labelSalePrice.text = self.textFieldSalePrice.text = [NSNumberFormatter localizedStringFromNumber:self.detailItem.salePrice numberStyle:NSNumberFormatterDecimalStyle];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self resignAllFirstResponders];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        self.textFieldName.hidden =
        self.textFieldRegularPrice.hidden =
        self.textFieldSalePrice.hidden =
        self.textViewDescription.hidden = NO;
    } else {
        self.textFieldName.hidden =
        self.textFieldRegularPrice.hidden =
        self.textFieldSalePrice.hidden =
        self.textViewDescription.hidden = YES;
        
        [self updateItem];
        [[DataStore sharedInstance] updateProduct:self.detailItem];
        
        [self resignAllFirstResponders];
    }
}

- (void)resignAllFirstResponders
{
    [self.textFieldName resignFirstResponder];
    [self.textFieldRegularPrice resignFirstResponder];
    [self.textFieldSalePrice resignFirstResponder];
    [self.textViewDescription resignFirstResponder];
}

- (void)updateItem
{
    self.detailItem.productPhoto = self.imageViewProductPhoto.image;
    self.labelName.text = self.detailItem.name = self.textFieldName.text;
    self.labelDescription.text = self.detailItem.explonation = self.textViewDescription.text;
    
    self.detailItem.regularPrice = @(self.textFieldRegularPrice.text.floatValue);
    self.labelRegularPrice.text = self.textFieldRegularPrice.text;
    
    self.detailItem.salePrice = @(self.textFieldSalePrice.text.floatValue);
    self.labelSalePrice.text = self.textFieldSalePrice.text;
}

- (void)animateViewFrameChangeForNotification:(NSNotification*)notification
{
    NSValue *begin = notification.userInfo[UIKeyboardFrameBeginUserInfoKey];
    NSValue *end = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    float delta = begin.CGRectValue.origin.y - end.CGRectValue.origin.y;
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.size.height -= delta;
                         self.view.frame = frame;
                     } completion:nil];
}

#pragma mark - ObjectViewController delegate methods

- (void)objectsViewController:(ColorsViewController *)controller didAddObject:(Entity *)entity {
    
    if ([controller isMemberOfClass:[ColorsViewController class]]) {
        assert([entity isMemberOfClass:[Color class]]);
        [[DataStore sharedInstance] addColor:(Color*)entity toProduct:self.detailItem];
    } else if ([controller isMemberOfClass:[StoresViewController class]]) {
        assert([entity isMemberOfClass:[Store class]]);
        [[DataStore sharedInstance] addStore:(Store*)entity toProduct:self.detailItem];
    }
}

- (void)objectsViewController:(ColorsViewController *)controller didRemoveObject:(Entity *)entity {
    
    if ([controller isMemberOfClass:[ColorsViewController class]]) {
        assert([entity isMemberOfClass:[Color class]]);
        [[DataStore sharedInstance] removeColor:(Color*)entity fromProduct:self.detailItem];
    } else if ([controller isMemberOfClass:[StoresViewController class]]) {
        assert([entity isMemberOfClass:[Store class]]);
        [[DataStore sharedInstance] removeStore:(Store*)entity fromProduct:self.detailItem];
    }
}

#pragma mark - Notification Responders

- (void)keyboardWillShowNotification:(NSNotification*)notification
{
    [self animateViewFrameChangeForNotification:notification];
}

- (void)keyboardWillHideNotification:(NSNotification*)notification
{
    [self animateViewFrameChangeForNotification:notification];
}

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.imageViewProductPhoto.image =
        self.detailItem.productPhoto = image;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        self.imageViewProductPhoto.image =
        self.detailItem.productPhoto = nil;
    }
    
    switch (buttonIndex) {
        case 1: {
            UIImagePickerController *galleryController = [[UIImagePickerController alloc] init];
            galleryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            galleryController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            galleryController.delegate = self;
            [self presentViewController:galleryController animated:YES completion:nil];
            break;
        }
            
        case 2: {
            UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
            cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            cameraController.delegate = self;
            [self presentViewController:cameraController animated:YES completion:nil];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Actions

- (IBAction)buttonColorsTapped:(id)sender {
    
    ColorsViewController *colorsViewController = [[ColorsViewController alloc] init];
    colorsViewController.objects = self.detailItem.colors;
    colorsViewController.delegate = self;
    colorsViewController.allowsEditing = YES;
    [self.navigationController pushViewController:colorsViewController animated:YES];
}

- (IBAction)buttonStoresTapped:(id)sender {
    
    StoresViewController *storesViewController = [[StoresViewController alloc] init];
    storesViewController.objects = self.detailItem.stores;
    storesViewController.delegate = self;
    storesViewController.allowsEditing = YES;
    [self.navigationController pushViewController:storesViewController animated:YES];
}

- (IBAction)buttonImageTapped:(id)sender {
    
    if (self.editing) {
        
        [self resignAllFirstResponders];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Load from Library", @"Take from Camera", nil];
        [actionSheet showInView:self.view];
        
    } else {
        FullScreenViewController *fullScreenViewController = [[FullScreenViewController alloc] init];
        fullScreenViewController.image = self.detailItem.productPhoto;
        [self.navigationController pushViewController:fullScreenViewController animated:YES];
    }
}

- (IBAction)buttonAllViewTapped:(id)sender {
    
    [self resignAllFirstResponders];
}

@end
