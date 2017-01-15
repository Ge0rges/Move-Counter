//
//  SCViewController.m
//  Sport Counter
//
//  Created by Georges Kanaan on 5/3/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "SCViewController.h"

@interface SCViewController ()

@end

@implementation SCViewController

@synthesize recordMoveButton, imageSourceOptions;

#pragma mark - UIView Delegate
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //add target to record move button
    [self.recordMoveButton addTarget:self action:@selector(startRecordingMove) forControlEvents:UIControlEventTouchUpInside];
    
    //make the tableView rounded
    self.tableView.clipsToBounds = YES;
    self.tableView.layer.cornerRadius = 5.0;
    
    //make sure arrays aren't null
    [self allocAndInitArrays];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{// on a differet thread setup things that are not needed immediately
        
        //set up the image picker
        //some random images
        imageChoices = @[@"jump",@"jumpRope",@"run",@"walk",@"pullUp",@"pushUp",@"sitUp", @"boxing"];
        
        //set up image picker
        self.imagePicker = [WFImagePickerControllerPlus new];
        self.imagePicker.galleryDataSource = self;
        self.imagePicker.delegate = self;
        self.imagePicker.galleryTitle = @"Pick an image for your Move";
        
        //set up action sheet
        self.imageSourceOptions = [[UIActionSheet alloc]
                                   initWithTitle:nil
                                   delegate:self
                                   cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                   otherButtonTitles:@"Take Photo",@"Choose Photo", @"Our Gallery", nil];
        
    });
}

#pragma mark - Alloc and Init
- (CMMotionManager *)motionManager {
    //check if motion manager is nil and if it  is alloc and init it
    
    if (!motionManager)  {motionManager = [CMMotionManager new]; [self.motionManager setDeviceMotionUpdateInterval:1/40];}
    
    return motionManager;
}

- (CMMotionActivityManager *)motionActivityManager {
    //check if motion manager is nil and if it  is alloc and init it
    
    if (!motionActivityManager) motionActivityManager = [CMMotionActivityManager new];
    
    return motionActivityManager;
}


- (CLLocationManager *)locationManager {
    //check if motion manager is nil and if it  is alloc and init it
    
    if (!locationManager)  {
        locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.activityType = CLActivityTypeFitness;
    }
    
    return locationManager;
}

- (void)allocAndInitArrays {
    //if arrays are null alloc and init them
    if (!accelerationXData) accelerationXData = [NSMutableArray new];
    if (!accelerationYData) accelerationYData = [NSMutableArray new];
    if (!accelerationZData) accelerationZData = [NSMutableArray new];
    if (!hashes) hashes = [NSMutableArray new];
    if (!locations) locations = [NSMutableArray new];
}

#pragma mark - Acceleromter data fetching & processing
- (void)startRecordingMove {
    
    //ask user for permission to when in use get location
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    //start getting location updates
    [self.locationManager startUpdatingLocation];
    
    //set the isCreating variable to YES
    isCreating = YES;
    
    //update the button
    [self.recordMoveButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.recordMoveButton removeTarget:self action:@selector(startRecordingMove) forControlEvents:UIControlEventTouchUpInside];
    [self.recordMoveButton addTarget:self action:@selector(stopRecordingMove) forControlEvents:UIControlEventTouchUpInside];
    
    //hide the views animated
    [UIView animateWithDuration:0.3 animations:^{
        
        self.tableView.alpha = 0;
        self.countLabel.alpha = 0;
        self.nameLabel.alpha = 0;
        self.goalLabel.alpha = 0;
        [self.view viewWithTag:250].alpha = 0;
        
    } completion:^(BOOL finished) {
        self.tableView.hidden = YES;
        self.countLabel.hidden = YES;
        self.nameLabel.hidden = YES;
        self.goalLabel.hidden = YES;
        [self.view viewWithTag:250].hidden = YES;
    }];
    
    //clear the arrays
    [accelerationXData removeAllObjects];
    [accelerationYData removeAllObjects];
    [accelerationXData removeAllObjects];
    
    //show a instruction alertView
    UIAlertView *instructionAlertview;
    if (recordingCount == 0) {
        instructionAlertview = [[UIAlertView alloc] initWithTitle:@"Please execute your move" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    } else if (recordingCount == 1) {
        instructionAlertview = [[UIAlertView alloc] initWithTitle:@"Please execute your move again" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    } else if (recordingCount == 2) {
        instructionAlertview = [[UIAlertView alloc] initWithTitle:@"Please execute your move one last time" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    }
    
    [instructionAlertview show];//show the alertView
    
    recordingCount += 1;
    
    if ([CMMotionActivityManager isActivityAvailable]) {//if we can get M7 data to make sure the device is not stationary or moving ina  car
        
        //start getting accelerometer data and M7 data
        [self.motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
            [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]  withHandler:^(CMDeviceMotion *data, NSError *error) {
                
                //start adding data to the accelerometer arrays
                //make the inner arrays containing the  userAcceleration only if the device is not stationnary or in a car
                if (activity.stationary == NO && activity.automotive == NO) {
                    __strong NSArray *localAccelerationXData = [NSArray arrayWithObjects:[NSNumber numberWithDouble:data.userAcceleration.x], nil];
                    __strong NSArray *localAccelerationYData = [NSArray arrayWithObjects:[NSNumber numberWithDouble:data.userAcceleration.y], nil];
                    __strong NSArray *localAccelerationZData = [NSArray arrayWithObjects:[NSNumber numberWithDouble:data.userAcceleration.x], nil];
                    
                    //save the inner  arrays
                    [accelerationXData addObject:localAccelerationXData];
                    [accelerationYData addObject:localAccelerationYData];
                    [accelerationZData addObject:localAccelerationZData];
                }
            }];
        }];
    } else {//no M7 data
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]  withHandler:^(CMDeviceMotion *data, NSError *error) {
            
            //start adding data to the accelerometer arrays
            //make the inner arrays containing the userAcceleration
            __strong NSArray *localAccelerationXData = [NSArray arrayWithObjects:[NSNumber numberWithDouble:data.userAcceleration.x], nil];
            __strong NSArray *localAccelerationYData = [NSArray arrayWithObjects:[NSNumber numberWithDouble:data.userAcceleration.y], nil];
            __strong NSArray *localAccelerationZData = [NSArray arrayWithObjects:[NSNumber numberWithDouble:data.userAcceleration.x], nil];
            
            //save the inner  arrays
            [accelerationXData addObject:localAccelerationXData];
            [accelerationYData addObject:localAccelerationYData];
            [accelerationZData addObject:localAccelerationZData];
            
        }];
    }
}

-(void)stopRecordingMove {
    //stop getting GPS data
    [self.locationManager stopUpdatingLocation];
    
    //disable the button
    [self.recordMoveButton removeTarget:self action:@selector(stopRecordingMove) forControlEvents:UIControlEventTouchUpInside];
    [self.recordMoveButton addTarget:self action:@selector(startRecordingMove) forControlEvents:UIControlEventTouchUpInside];
    
    //stop the device motion updates and hide the view
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionActivityManager stopActivityUpdates];
    
    //process move
    [self processMove];
}


#pragma mark - UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[SCMove allMoves] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MoveCell"];//check if the cell was already created
    
    //get the move
    NSArray *move = [SCMove moveWithNumber:(int)indexPath.row+1];
    
    //round the imageView and set the image
    if (![[move objectAtIndex:ISDEFAULTIMAGE_INDEX_IN_MOVES_ARRAY] boolValue]) {
        UIImage *moveImage = [move objectAtIndex:IMAGE_INDEX_IN_MOVES_ARRAY];
        [cell.imageView setImage:[moveImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(50, 50) interpolationQuality:kCGInterpolationHigh]];
    } else {
        UIImage *image = [UIImage imageNamed:[move objectAtIndex:IMAGE_INDEX_IN_MOVES_ARRAY]];
        [cell.imageView setImage:image];
    }
    
    cell.imageView.layer.cornerRadius = 25.0;
    cell.imageView.clipsToBounds = YES;
    
    //set the buttons
    cell.rightUtilityButtons = [self rightButtons];
    
    cell.delegate = self;
    
    //set the name of the move to the cell text label
    [cell.textLabel setText:[move objectAtIndex:NAME_INDEX_IN_MOVES_ARRAY]];
    
    //set the number of moves all time to the detail label
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"Done %@ times total.",[move objectAtIndex:COUNT_INDEX_IN_MOVES_ARRAY]]];
    
    
    return cell;
}

- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0] title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor: [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] title:@"Delete"];
    
    return rightUtilityButtons;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isTracking == YES) {//check if it was tracking and the user switched to this move directly
        //he was in a session finish it
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
    } else {
        //ask user for permission to always get location
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0) {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        //he was not in a session continue normally (start a new one)
        //clear locations
        [locations removeAllObjects];
        
        //start GPS data so we can get the location of the user
        [self.locationManager startUpdatingLocation];
        
        //look for move
        NSArray *move = [SCMove moveWithNumber:(int)indexPath.row+1];//get move
        [self startLookingForMove:move];//start looking for move
        
        //update the counts for this move
        startingCount = [[move objectAtIndex:COUNT_INDEX_IN_MOVES_ARRAY] intValue];
        count = 0;
        
        //tracking
        isTracking = YES;
        
        //set the start date
        startDate = [NSDate date];
        
        //reset goal
        goal = 10;
        [self.goalLabel setText:[NSString stringWithFormat:@"Goal: %i", goal]];
        
        //set the name label
        [self.nameLabel setText:[[SCMove moveWithNumber:(int)indexPath.row+1] objectAtIndex:NAME_INDEX_IN_MOVES_ARRAY]];
        
        //update the count label
        [self.countLabel setText:@"0"];
        
        //set the tag of the label to be the indexPath row +1 so we can get the move later
        self.countLabel.tag = indexPath.row+1;
    }
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Stop the motion activity
    [self.motionActivityManager stopActivityUpdates];
    
    //Stop the device motion updates
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionActivityManager stopActivityUpdates];
    
    //stop getting GPS data
    [self.locationManager stopUpdatingLocation];
    
    //show the winning page
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SCWinningPageViewController *wpvc = [storyboard instantiateViewControllerWithIdentifier:@"winningpageVC"];
    
    //configure the properties
    [wpvc setCount:count];
    [wpvc setMove:[SCMove moveWithNumber:(int)self.countLabel.tag]];
    [wpvc setGoal:goal];
    [wpvc setLocations:locations];
    
    //show the page
    [self presentViewController:wpvc animated:YES completion:nil];
    
    //not tracking
    isTracking = NO;
    
    //set the name label
    [self.nameLabel setText:@"No Move Selected"];
    
    //update the count label
    [self.countLabel setText:@"0"];
    
    //update and save total count to the move
    BOOL moveSaved = [SCMove setCount:count+startingCount forMoveWithNumber:(int)self.countLabel.tag];
    if (!moveSaved) {
        [[[UIAlertView alloc] initWithTitle:@"Error Saving Move Progress" message:@"We encountered an error saving the move progress. This only means the total number will not get updated. You can still use this move. Please contact us if this keeps happening via the App Store." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }
    
    //refresh the cell to update the count
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    //assign the global variable so we can access the cell later
    swipedCell = cell;
    
    //deselect the currently selected cell
    if (cell == [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]]) {
        [self tableView:self.tableView didDeselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }
    
    switch (index) {
        case 0:
        {
            //Modify button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [self showModifyActionSheetWithNumber:(int)cellIndexPath.row+1];
            
            break;
        }
        case 1:
        {
            //Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [self deleteMoveWithNumber:(int)cellIndexPath.row+1];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == renameAlertView && buttonIndex == 1) {
        //rename the move
        if ([alertView textFieldAtIndex:0].text.length != 0) {
            [SCMove renameMoveWithNumber:(int)renameAlertView.tag andName:[alertView textFieldAtIndex:0].text];
        } else {
            //set a default name
            [SCMove renameMoveWithNumber:(int)renameAlertView.tag andName:[NSString stringWithFormat:@"Move n°%i", (int)renameAlertView.tag]];
        }
        
        //reload the tableView
        [self.tableView reloadData];
        
    } else if (buttonIndex == 1 && alertView == chooseMoveNameAlertView) {
        if ([alertView textFieldAtIndex:0].text.length != 0) {//if the user input text set it otherwise generate the Move n°%i title
            moveName = [alertView textFieldAtIndex:0].text;
        } else {
            //set a default name
            int numberOfMoves = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfMoves"];
            moveName = [NSString stringWithFormat:@"Move n°%i", numberOfMoves+1];
        }
        
        //saving is handled by UIPickerViewDelegate so just continue the setup sequence
        mapAlertView = [[UIAlertView alloc] initWithTitle:@"Mapping" message:@"Would you like us to track your location while you execute moves to see them on a map when finished? (Useful for walking, running..." delegate:self cancelButtonTitle:nil otherButtonTitles:@"No", @"Yes", nil];
        [mapAlertView show];
        
    } else if (alertView == mapAlertView) {
        if (buttonIndex == 1) {
            wantsMap = YES;//set the bool to yes so we can use it later when saving
            //show the choose image alert view
            [self.imageSourceOptions showInView:self.view];
            
        } else {
            wantsMap = NO;//set the bool to no so we can use it later when saving
            //show the choose image alert view
            [self.imageSourceOptions showInView:self.view];
        }
        
        //hide the utility buttons
        [swipedCell hideUtilityButtonsAnimated:YES];
        swipedCell = nil;
        
    } else if (alertView == changeMapAlertView) {//if it is the change map ALertView
        if (buttonIndex == 1) {//if the button index is 1 so YES
            [SCMove setWantsMapping:YES forMoveWithNumber:(int)changeMapAlertView.tag];//set to YES
        } else {
            [SCMove setWantsMapping:NO forMoveWithNumber:(int)changeMapAlertView.tag];//set to NO
        }
    } else if (buttonIndex == 0) {
        //change recordMove button text and enable it
        [self.recordMoveButton setTitle:@"Record Move" forState:UIControlStateNormal];
        [self.recordMoveButton setEnabled:YES];
        
        //stop motion updates
        [self.motionActivityManager stopActivityUpdates];
        [self.motionManager stopDeviceMotionUpdates];
        
        //set recording count to 0
        recordingCount = 0;
        
        //show the views
        self.tableView.hidden = NO;
        self.countLabel.hidden = NO;
        self.nameLabel.hidden = NO;
        self.goalLabel.hidden = NO;
        [self.view viewWithTag:250].hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.alpha = 1;
            self.countLabel.alpha = 1;
            self.nameLabel.alpha = 1;
            self.goalLabel.alpha = 1;
            [self.view viewWithTag:250].alpha = 1;
            
        }];
        
        
        //reload the tableView
        [self.tableView reloadData];
    }
}

#pragma mark - Editing Moves
-(IBAction)updateGoal:(id)sender {
    UIStepper *goalStepper = (UIStepper *)sender;
    goal = goalStepper.value;
    [self.goalLabel setText:[NSString stringWithFormat:@"Goal: %i", goal]];
}

-(void)showModifyActionSheetWithNumber:(int)number {
    //get the move for its name
    NSArray *move = [SCMove moveWithNumber:number];
    NSString *name = [move objectAtIndex:NAME_INDEX_IN_MOVES_ARRAY];
    
    //show a action sheet containing the update button depending if a update is available
    UIActionSheet *modifyMove = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Modify %@", name] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Rename", @"Change Image", @"Change Mapping", nil];
    
    modifyMove.tag = number;
    modifyMove.actionSheetStyle = UIActionSheetStyleAutomatic;
    [modifyMove showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet != imageSourceOptions) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            //Cancel Button Clicked
            [swipedCell hideUtilityButtonsAnimated:YES];
            swipedCell = nil;
        } else  if (buttonIndex == actionSheet.destructiveButtonIndex) {
            //Delete Button Clicked
            [self deleteMoveWithNumber:(int)actionSheet.tag];
        } else if (buttonIndex == 1) {
            //Rename Button Clicked
            [self renameMoveWithNumber:(int)actionSheet.tag];
        } else if (buttonIndex == 2) {
            //change image button clicked
            [self.imageSourceOptions showInView:self.view];
            [self.imageSourceOptions setTag:actionSheet.tag];
        } else if (buttonIndex == 3) {
            //change mapping button clicked
            [self changeMappingForMoveWithNumber:(int)actionSheet.tag];
        }
    } else {
        //image action sheet
        if (actionSheet.cancelButtonIndex != buttonIndex) {
            switch (buttonIndex) {
                case 0:
                    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        [[[UIAlertView alloc] initWithTitle:nil message:@"No camera on device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                        return;
                    }
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:self.imagePicker animated:YES completion:nil];
                    break;
                case 1:
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self presentViewController:self.imagePicker animated:YES completion:nil];
                    break;
                case 2:
                    self.imagePicker.sourceType = JWSimpleImagePickerControllerSourceTypeGallery;
                    [self presentViewController:self.imagePicker animated:YES completion:nil];
                    break;
                default:
                    break;
            }
        } else {
            //show the views and enable the recording button animated
            self.tableView.hidden = NO;
            self.recordMoveButton.hidden = NO;
            self.countLabel.hidden = NO;
            self.nameLabel.hidden = NO;
            self.goalLabel.hidden = NO;
            [self.view viewWithTag:250].hidden = NO;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.tableView.alpha = 1;
                self.recordMoveButton.alpha = 1;
                self.countLabel.alpha = 1;
                self.nameLabel.alpha = 1;
                self.goalLabel.alpha = 1;
                [self.view viewWithTag:250].alpha = 1;
                
            }];
            
            //reload the tableView
            [self.tableView reloadData];
            
            //not creating anymore
            moveName = nil;
            isCreating = NO;
            
        }
    }
}

-(void)deleteMoveWithNumber:(int)number {
    if ([self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:number-1 inSection:0]].isSelected) {
        [self tableView:self.tableView didDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:number-1 inSection:0]];
    }
    
    [SCMove removeMoveNumber:number];
    
    //update the tableView
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)renameMoveWithNumber:(int)number {
    renameAlertView = [[UIAlertView alloc] initWithTitle:@"Rename Move to:" message:nil delegate:self cancelButtonTitle:@"Cancel"otherButtonTitles:@"Rename", nil];
    renameAlertView.tag = number;
    [renameAlertView textFieldAtIndex:0].placeholder = @"Please choose a name for your move";
    renameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [renameAlertView show];
}


-(void)changeMappingForMoveWithNumber:(int)number {
    changeMapAlertView = [[UIAlertView alloc] initWithTitle:@"Mapping" message:@"Would you like us to track your location while you execute moves to see them on a map when finished? (Useful for walking, running...). Your location is shared with noone and not sent to any server." delegate:self cancelButtonTitle:nil otherButtonTitles:@"No", @"Yes", nil];
    changeMapAlertView.tag = number;
    [changeMapAlertView show];
    
}

#pragma mark - Detecting Moves
-(void)processMove {
    //sort the arrays from smallest to biggest
    NSArray *accelerationXDataSorted = [accelerationXData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([[obj1 objectAtIndex:0] doubleValue] > [[obj1 objectAtIndex:0] doubleValue])
            return NSOrderedAscending;
        else if ([[obj1 objectAtIndex:0] doubleValue] < [[obj1 objectAtIndex:0] doubleValue])
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
    NSArray *accelerationYDataSorted = [accelerationYData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([[obj1 objectAtIndex:0] doubleValue] > [[obj1 objectAtIndex:0] doubleValue])
            return NSOrderedAscending;
        else if ([[obj1 objectAtIndex:0] doubleValue] < [[obj1 objectAtIndex:0] doubleValue])
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
    NSArray *accelerationZDataSorted = [accelerationZData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([[obj1 objectAtIndex:0] doubleValue] > [[obj1 objectAtIndex:0] doubleValue])
            return NSOrderedAscending;
        else if ([[obj1 objectAtIndex:0] doubleValue] < [[obj1 objectAtIndex:0] doubleValue])
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    //get the 5 biggest values in the sorted ranges
    NSArray *fiveBiggestAccelerationXDataSorted = [accelerationXDataSorted subarrayWithRange:NSMakeRange(0,5)];
    NSArray *fiveBiggestAccelerationYDataSorted = [accelerationYDataSorted subarrayWithRange:NSMakeRange(0,5)];
    NSArray *fiveBiggestAccelerationZDataSorted = [accelerationZDataSorted subarrayWithRange:NSMakeRange(0,5)];
    
    //generate the hash: hash = (((x+y+z)*100));
    for (int i = 0; i < [fiveBiggestAccelerationXDataSorted count]; i++) {
        //get the value
        double x  = [[[fiveBiggestAccelerationXDataSorted objectAtIndex:i] objectAtIndex:0] doubleValue];
        double y  = [[[fiveBiggestAccelerationYDataSorted objectAtIndex:i] objectAtIndex:0] doubleValue];
        double z  = [[[fiveBiggestAccelerationZDataSorted objectAtIndex:i] objectAtIndex:0] doubleValue];
        
        //generate the hash
        int hash = ((x+y+z)*100);
        if (hash > 10 || hash < -10) [hashes addObject:[NSNumber numberWithInt:hash]];//save it if it isn't negligeable
    }
    
    if (recordingCount == 3) {
        if (hashes.count >= 5) {//check if it is a valid move with enough hashes to be accurate
            //stop accelerometer data
            [self.motionManager stopDeviceMotionUpdates];
            [self.motionActivityManager stopActivityUpdates];
            
            //remove duplicates
            hashes = [NSMutableArray arrayWithArray:[[NSSet setWithArray:hashes] allObjects]];
            
            //disable button
            [self.recordMoveButton setTitle:@"Processing..." forState:UIControlStateNormal];
            [self.recordMoveButton setEnabled:NO];
            
            //show name alertView
            chooseMoveNameAlertView = [[UIAlertView alloc] initWithTitle:@"Name the move:" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create move!", nil];
            
            chooseMoveNameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [chooseMoveNameAlertView textFieldAtIndex:0].placeholder = @"Please choose a name for your move";
            [chooseMoveNameAlertView show];
            
            //reset recording count
            recordingCount = 0;
            
        } else {//not a valid move
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"We encountered an error generating a ID for this move. Please try again and make sure to have the phone on your person." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
        
    } else {
        [self startRecordingMove];
    }
}

-(void)startLookingForMove:(NSArray *)move {
    if ([CMMotionActivityManager isActivityAvailable]) {//if we can get M7 data
        //start getting motion activity M7 data
        [motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
            
            //start getting the acceleromter data and checking for moves
            [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]  withHandler:^(CMDeviceMotion *data, NSError *error) {
                
                //generate the hash: hash = ((x+y+z)*100);
                double x = data.userAcceleration.x;
                double y = data.userAcceleration.y;
                double z = data.userAcceleration.z;
                
                int hash = ((x+y+z)*100);
                
                //check the hash agaisnt all saved hashes for the move
                NSArray *lclhashes = [move objectAtIndex:HASHES_INDEX_IN_MOVES_ARRAY];
                for (int i = 0; i < [lclhashes count]; i++) {
                    int savedHash = [[lclhashes objectAtIndex:i] intValue];
                    
                    if (savedHash >= hash+2 && savedHash <= hash+2 && activity.stationary == NO && activity.automotive == NO) {//make sure the user is not in a car or is stationary
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            //set the timerDate to now and set the timer so that we only increment count once per move
                            timerDate = [NSDate date];
                            if (!timer) {
                                timer = [NSTimer scheduledTimerWithTimeInterval:1/40 target:self selector:@selector(countRoutine) userInfo:nil repeats:YES];
                            }
                        });
                        
                        //stop the loop
                        break;
                    }
                    
                }
            }];
        }];
    } else {//no M7
        //start getting the acceleromter data and checking for moves
        [self.motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init]  withHandler:^(CMDeviceMotion *data, NSError *error) {
            
            //generate the hash: hash = ((x+y+z)*100);
            double x = data.userAcceleration.x;
            double y = data.userAcceleration.y;
            double z = data.userAcceleration.z;
            
            int hash = ((x+y+z)*100);
            
            //check the hash agaisnt all saved hashes for the move
            NSArray *lclhashes = [move objectAtIndex:HASHES_INDEX_IN_MOVES_ARRAY];
            for (int i = 0; i < [lclhashes count]; i++) {
                int savedHash = [[lclhashes objectAtIndex:i] intValue];
                
                if (savedHash >= hash+2 && savedHash <= hash+2) {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        //set the timerDate to now and set the timer so that we only increment count once per move
                        timerDate = [NSDate date];
                        if (!timer) {
                            timer = [NSTimer scheduledTimerWithTimeInterval:1/40 target:self selector:@selector(countRoutine) userInfo:nil repeats:YES];
                        }
                    });
                    
                    //stop the loop
                    break;
                }
                
            }
        }];
    }
}

-(void)countRoutine {
    
    NSTimeInterval interval = -[timerDate timeIntervalSinceNow]; // return value will be negative, so change sign
    if(interval >= 0.5 && isTracking) {//check if there is 0.5 second difference since this block was called
        //update count and label
        count += 1;
        [self.countLabel setText:[NSString stringWithFormat:@"%i", count]];
        
        //stop the timer
        [timer invalidate];
        timer = nil;
        timerDate = nil;
        
    }
}

#pragma mark - JWImagePickerController
#pragma mark JWImagePickerControllerPlusDelegate

-(void)imagePickerController:(WFImagePickerControllerPlus *)picker didFinishPickingImage:(UIImage *)image defaultImage:(BOOL)defaultImage imageName:(NSString *)defaultImageName
{
    if (isCreating) {
        //show a wait alert while we filter through the data
        UIAlertView *waitAlert = [[UIAlertView alloc] initWithTitle:@"Generating move..." message:@"Please wait while we generate the move for you." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [waitAlert show];
        
        //resize the image if it isn't a default image
        BOOL moveSaved;
        if (!defaultImage) {
            UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(50, 50) interpolationQuality:kCGInterpolationHigh];
            
            //create the move
            moveSaved = [SCMove createMoveWithHashs:hashes count:0 image:resizedImage defaultImage:defaultImage imageName:nil wantsMapping:wantsMap andName:moveName];
        } else {
            //create the move
            moveSaved = [SCMove createMoveWithHashs:hashes count:0 image:nil defaultImage:defaultImage imageName:defaultImageName wantsMapping:wantsMap andName:moveName];
        }
        
        if (!moveSaved) {//check if we failed to save the move
            [[[UIAlertView alloc] initWithTitle:@"Error Saving Move" message:@"We encountered an error saving the move. Please try again later or contact us if this keeps happening via the App Store." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
        //reset the record move button text and enable it
        [self.recordMoveButton setTitle:@"Record Move" forState:UIControlStateNormal];
        [self.recordMoveButton setEnabled:YES];
        
        //clear hashes
        [hashes removeAllObjects];
        
        //show the views and enable the recording button animated
        self.tableView.hidden = NO;
        self.recordMoveButton.hidden = NO;
        self.countLabel.hidden = NO;
        self.nameLabel.hidden = NO;
        self.goalLabel.hidden = NO;
        [self.view viewWithTag:250].hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.alpha = 1;
            self.recordMoveButton.alpha = 1;
            self.countLabel.alpha = 1;
            self.nameLabel.alpha = 1;
            self.goalLabel.alpha = 1;
            [self.view viewWithTag:250].alpha = 1;
            
        }];
        
        [self dismissViewControllerAnimated:YES completion:^{
            //update the tableView
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            //dismiss the generating alert
            [waitAlert dismissWithClickedButtonIndex:0 animated:YES];
            
            //clear the picker
            self.imagePicker = nil;
            
            //set up image picker
            self.imagePicker = [WFImagePickerControllerPlus new];
            self.imagePicker.galleryDataSource = self;
            self.imagePicker.delegate = self;
            self.imagePicker.galleryTitle = @"Pick an image for your Move";
            
            //set up action sheet
            self.imageSourceOptions = [[UIActionSheet alloc]
                                       initWithTitle:nil
                                       delegate:self
                                       cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                       otherButtonTitles:@"Take Photo",@"Choose Photo", @"Our Gallery", nil];
            
        }];
        
        //not creating anymore
        isCreating = NO;
        moveName = nil;
        
    } else {
        //not creating a new move change the existings move's image
        if (!defaultImage) {
            UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(50, 50) interpolationQuality:kCGInterpolationHigh];
            [SCMove setImage:resizedImage forMoveWithNumber:(int)self.imageSourceOptions.tag defaultImage:defaultImage imageName:nil];
        } else {
            [SCMove setImage:nil forMoveWithNumber:(int)self.imageSourceOptions.tag defaultImage:defaultImage imageName:defaultImageName];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            //update the tableView
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            //clear the picker
            self.imagePicker = nil;
            
            //set up image picker
            self.imagePicker = [WFImagePickerControllerPlus new];
            self.imagePicker.galleryDataSource = self;
            self.imagePicker.delegate = self;
            self.imagePicker.galleryTitle = @"Pick an image for your Move";
            
            //set up action sheet
            self.imageSourceOptions = [[UIActionSheet alloc]
                                       initWithTitle:nil
                                       delegate:self
                                       cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                       otherButtonTitles:@"Take Photo",@"Choose Photo", @"Our Gallery", nil];
            
        }];
    }
    
}

- (void)imagePickerControllerDidGoBack:(WFImagePickerControllerPlus *)picker
{
    if (isCreating) {//if it is creating then show the options again
        [self.imageSourceOptions showInView:self.view];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        //clear the picker
        self.imagePicker = nil;
        
        //set up image picker
        self.imagePicker = [WFImagePickerControllerPlus new];
        self.imagePicker.galleryDataSource = self;
        self.imagePicker.delegate = self;
        self.imagePicker.galleryTitle = @"Pick an image for your Move";
        
    }];
    
}

#pragma mark JWImagePickerControllerGalleryDataSource


-(UIImage *)imagePickerController:(WFImagePickerControllerPlus *)picker galleryImageAtIndex:(NSUInteger) index
{
    return [UIImage imageNamed:[imageChoices objectAtIndex:index]];
}

-(int)numberOfImagesInGalleryForImagePicker:(WFImagePickerControllerPlus *)picker
{
    return (int)[imageChoices count];
}

#pragma mark - CoreLocation
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)lclLocations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation *location = [lclLocations lastObject];
    NSDate *eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0 && location.horizontalAccuracy <= 10) {
        // If the event is recent and the accuracy is acceptable do something with it.
        [locations addObject:location];
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end