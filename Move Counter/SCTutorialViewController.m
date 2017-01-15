//
//  SCTutorialViewController.m
//  Move Counter
//
//  Created by Georges Kanaan on 5/25/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "SCTutorialViewController.h"

@implementation SCTutorialViewController

-(void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Tutorial
-(IBAction)playTutorial {
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[[NSBundle mainBundle] URLForResource:@"tutorial" withExtension:@"mp4"]];
    player.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [player.moviePlayer prepareToPlay];
    [self presentMoviePlayerViewControllerAnimated:player];
    [player.moviePlayer play];
    
}

-(void)removeFile:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directory {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, extension]]]) {
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@.%@", directory, fileName, extension] error:&error];
    }
}


-(IBAction)startSetup:(id)sender {

    //present the main view silently and start the recording process
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SCViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mainVC"];
    [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [vc startRecordingMove];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    //delete the tutorial video to save space
    [self removeFile:@"tutorial" ofType:@"mov" inDirectory:[[NSBundle mainBundle] bundlePath]];
    
    //mark the page as viewed
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tutorialSeenPage2"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
