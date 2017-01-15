//
//  SCViewController.h
//  Sport Counter
//
//  Created by Georges Kanaan on 5/3/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "SCMove.h"
#import "WFImagePickerControllerPlus.h"
#import "SWTableViewCell.h"
#import "SCWinningPageViewController.h"
#import "UIImage+Resize.h"

@interface SCViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate,WFImagePickerControllerGalleryDataSource, WFImagePickerControllerPlusDelegate, UIActionSheetDelegate, SWTableViewCellDelegate, CLLocationManagerDelegate> {
    
    CMMotionManager *motionManager;
    CMMotionActivityManager *motionActivityManager;
    CLLocationManager *locationManager;
   
    NSArray *imageChoices;

    NSMutableArray *accelerationXData;
    NSMutableArray *accelerationYData;
    NSMutableArray *accelerationZData;
    NSMutableArray *hashes;
    NSMutableArray *locations;
    
    UIAlertView *renameAlertView;
    UIAlertView *chooseMoveNameAlertView;
    UIAlertView *mapAlertView;
    UIAlertView *changeMapAlertView;

    NSDate *timerDate;
    NSDate *startDate;
    
    NSDictionary *activityTypes;
    
    NSString *moveName;
    
    BOOL isCreating;
    BOOL isTracking;
    BOOL isMoving;
    BOOL wantsMap;
    
    int count;
    int startingCount;
    int recordingCount;
    int goal;
    
    SWTableViewCell *swipedCell;
    
    NSTimer *timer;
}

@property (readonly) CMMotionManager *motionManager;
@property (readonly) CMMotionActivityManager *motionActivityManager;
@property (readonly) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIButton *recordMoveButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) WFImagePickerControllerPlus *imagePicker;
@property (nonatomic, retain) UIActionSheet *imageSourceOptions;
@property (strong, nonatomic) IBOutlet UILabel *goalLabel;
@property (strong, nonatomic) IBOutlet UIStepper *goalStepper;

-(void)startRecordingMove;

@end
