//
//  MapViewController.m
//  thirdeye
//
//  Created by Christopher Neale on 5/7/12.
//  Copyright (c) 2012 New York University. All rights reserved.
//

#import "MapViewController.h"
#include "AppDelegate.h"
#include "LocationAnnotationView.h"
#define DEFAULT_LAT  0.050812;
#define DEFAULT_LONG 0.022135;

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize map;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *location = [[delegate the_ARController].locationManager location];
    
    [map setCenterCoordinate:location.coordinate animated:YES];
    
    MKCoordinateRegion theRegion = map.region;
    
    //Make the map zoomed in arbitrarily when the view gets loaded
    theRegion.span.longitudeDelta = DEFAULT_LONG;
    theRegion.span.latitudeDelta  = DEFAULT_LAT; 
    
    [map setRegion:theRegion animated:YES];
    [self mapView:self.map regionDidChangeAnimated:NO];
    
    [super viewWillAppear:animated]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(MKAnnotationView*)mapView:(MKMapView *) mapView
          viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    if([annotation isKindOfClass:[LocationAnnotationView class]]){
        MKPinAnnotationView *pinView = (MKPinAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:@"LocationAnnotationView"];
        if(!pinView)
        {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"LocationAnnotationView"];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            pinView.draggable =     YES;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(myShowDetailsMethod:) forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = rightButton;
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
    }
    return nil;
}

-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated 
{
    NSArray *oldAnnotations = mapView.annotations;
    [mapView removeAnnotations:oldAnnotations];
    
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSArray *newItems = [delegate listOfLocations];
    [mapView addAnnotations:newItems];
}


-(void) mapView:(MKMapView *)mapView 
        annotationView:(MKAnnotationView *)annotationView
        didChangeDragState:(MKAnnotationViewDragState)newState 
        fromOldState:(MKAnnotationViewDragState)oldState
{
    if(newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        [annotationView.annotation setCoordinate:droppedAt]; 
    }
}



@end
