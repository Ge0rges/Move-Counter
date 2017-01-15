//
//  SCRedirectionViewController.m
//  Move Counter
//
//  Created by Georges Kanaan on 5/25/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "SCRedirectionViewController.h"

@implementation SCRedirectionViewController

-(void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)prefersStatusBarHidden {
    return YES;//hide the status bar
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //get the stroyboard top present he views
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    //show the tutorial pVC if it was never shown
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"tutorialSeenPage2"]) {
        //not seen
        SCTutorialViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"tutorialVC"];
        [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:vc animated:YES completion:nil];
        
    } else {
        SCViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainVC"];
        [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
