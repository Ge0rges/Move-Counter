//
//  SCWinningPageViewController.m
//  Move Counter
//
//  Created by Georges Kanaan on 5/28/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "SCWinningPageViewController.h"

@implementation SCWinningPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //set wether we should hide the map button depedning on if we have locations and if mapping enabled
    if (![[_move objectAtIndex:WANTSMAPPING_INDEX_IN_MOVES_ARRAY] boolValue] || self.locations.count == 0) {
        self.mapButton.hidden = YES;
    }
    
    //update the labels
    NSString *name = [self.move objectAtIndex:NAME_INDEX_IN_MOVES_ARRAY]; //get the name of the move
    [self.countLabel setText:[NSString stringWithFormat:@"%i", _count]];
    [self.moveNameLabel setText:name];
    
    //update the label to say encourage the user
    if (_count < _goal) {
        if (_count == 0) {
            [self.encouragementLabel setText:@"Try and put more effort into it next time."];
        } else if (_count <= _goal-40) {
            [self.encouragementLabel setText:@"This is getting serious!"];
        } else if (_count <= _goal-10) {
            [self.encouragementLabel setText:@"Keep up the good work!"];
        } else if (_count <= 20) {
            [self.encouragementLabel setText:@"We're off to a good start!"];
        } else if (_count <= 30) {
            [self.encouragementLabel setText:@"If we could, we would give you a cookie :D"];
        } else if (_count <= 40) {
            [self.encouragementLabel setText:@"You're awesome!"];
        }
		
    } else if (_count == _goal) {
        [self.encouragementLabel setText:[NSString stringWithFormat:@"You reached your goal of %i! You'll be fit in no time.", _goal]];
    } else if (_count > _goal) {
        [self.encouragementLabel setText:[NSString stringWithFormat:@"You surpassed your goal of %i by %i! You're extremely fit!", _goal, _count-_goal]];
    }
    
}

- (IBAction)showMap:(id)sender {
    //show the winning page
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SCMapViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"mapVC"];
    
    //show the page
    [self presentViewController:mvc animated:YES completion:^{
        [mvc drawRoute:_locations];//draw the route
    }];

}

- (IBAction)showShareSheet:(id)sender {
    //set the activity view controll options
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:[NSString stringWithFormat:@"I did %@ %i times today! All tracked with Sports Counter.", [self.move objectAtIndex:NAME_INDEX_IN_MOVES_ARRAY ], self.count], nil] applicationActivities:nil];
    
    //exclude some type of activities such as print and airdrop
    NSArray *excludedActivities = @[UIActivityTypePrint, UIActivityTypeAirDrop];
    controller.excludedActivityTypes = excludedActivities;
    
    //present the share sheet
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (IBAction)closePage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
