//
//  SCMapViewController.m
//  Move Counter
//
//  Created by Georges Kanaan on 6/1/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "SCMapViewController.h"

@implementation SCMapViewController

@synthesize map;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)prefersStatusBarHidden {
    return YES;//hide the status bar
}

- (void)drawRoute:(NSArray *)path {
    //create the MKPolyline
    NSInteger numberOfSteps = path.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        CLLocation *location = [path objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        
        coordinates[index] = coordinate;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    [self.map addOverlay:polyLine];

    //zoom in on the start of the line
    [self zoomToPolyLine:map polyLine:polyLine animated:YES];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 50.0;
    
    return polylineView;
}

-(void)zoomToPolyLine:(MKMapView*)lclmap polyLine:(MKPolyline*)polyLine animated:(BOOL)animated {
    //zoom the map to fit the polyline
    MKPolygon *polygon = [MKPolygon polygonWithPoints:polyLine.points count:polyLine.pointCount];
    
    [lclmap setRegion:MKCoordinateRegionForMapRect([polygon boundingMapRect]) animated:animated];
}

-(IBAction)changeMapType:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        map.mapType = MKMapTypeStandard;
    } else if (sender.selectedSegmentIndex == 1) {
        map.mapType = MKMapTypeSatellite;
    } else if (sender.selectedSegmentIndex == 2) {
        map.mapType = MKMapTypeHybrid;
    }
}

-(IBAction)showUserLocation:(id)sender {
    //zoom in on the user
    map.showsUserLocation = YES;//show the user
    [map setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//wait for the mode to take effect then cancel it
        [map setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    });
}

-(IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
