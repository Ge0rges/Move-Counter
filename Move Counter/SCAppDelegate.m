//
//  SCAppDelegate.m
//  Sport Counter
//
//  Created by Georges Kanaan on 5/3/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "SCAppDelegate.h"

@implementation SCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isNotInitialLaunchSC"]) {
        
        //first time the app launches configure variables
        //set the number of moves to 0
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"numberOfMoves"];
        
        //create a directory for our plists and images
        // Fetch path for document directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //create the directories needed to store info
        [[NSFileManager defaultManager] createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"MovePlists"] withIntermediateDirectories:NO attributes:nil error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"MoveImages"] withIntermediateDirectories:NO attributes:nil error:nil];

        //not a first launch anymore
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isNotInitialLaunchSC"];
    }
    
    //disale the timer
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    return YES;
}

@end
