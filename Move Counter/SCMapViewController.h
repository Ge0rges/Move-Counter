//
//  SCMapViewController.h
//  Move Counter
//
//  Created by Georges Kanaan on 6/1/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SCMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *map;

- (void)drawRoute:(NSArray *)path;

@end
