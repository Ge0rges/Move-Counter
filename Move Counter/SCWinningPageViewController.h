//
//  SCWinningPageViewController.h
//  Move Counter
//
//  Created by Georges Kanaan on 5/28/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCMove.h"
#import "SCMapViewController.h"

@interface SCWinningPageViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UILabel *encouragementLabel;
@property (strong, nonatomic) IBOutlet UILabel *moveNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *indicatorLabel;
@property (strong, nonatomic) IBOutlet UIButton *mapButton;
@property (strong, nonatomic) NSArray *move;
@property (strong, nonatomic) NSArray *locations;
@property int count;
@property int goal;

@end
