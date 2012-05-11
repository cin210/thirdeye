//
//  LocationViewController.m
//  thirdeye
//
//  Created by Christopher Neale on 4/23/12.
//  Copyright (c) 2012 New York University. All rights reserved.
//

#import "LocationViewController.h"
#include "Location.h" 
#include "AppDelegate.h"

#define DEFAULT_LAT 0.014165;
#define DEFAULT_LONG 0.032520;

@interface LocationViewController ()

@end

@implementation LocationViewController

@synthesize  nameField;
@synthesize descriptionField;
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize name = _name;
@synthesize description = _description;
@synthesize dataLabel = _dataLabel;
@synthesize dataObject = _dataObject;
@synthesize map;
@synthesize locationView;

- (IBAction)createMarker
{  
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (nameField.text  == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Woops"
                                                        message:@"Please name this location."
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OK Button", @"OK") 
                                              otherButtonTitles:nil, nil];
        [alert show]; 
    }
    else{
        [delegate addMarkerWithName:nameField.text Description: descriptionField.text]; 
    }
}




- (void)viewDidLoad
{    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.dataLabel = nil;
}

-(IBAction)textFieldDoneEditing:(id)sender
{ 
    [sender resignFirstResponder];
}

-(IBAction)backgroundTap:(id)sender
{  
    [sender resignFirstResponder];
    [nameField resignFirstResponder];
    [descriptionField resignFirstResponder];  
}

- (void)viewWillAppear:(BOOL)animated
{
   
    
    self.nameField.text = nil;
    self.descriptionField.text = nil;
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *location = [[delegate the_ARController].locationManager location];
    
    [map setCenterCoordinate:location.coordinate animated:YES];
    MKCoordinateRegion theRegion = map.region;
    
    //Make the map zoomed in arbitrarily when the view gets loaded
    theRegion.span.longitudeDelta = DEFAULT_LONG;
    theRegion.span.latitudeDelta  = DEFAULT_LAT; 
     
    [map setRegion:theRegion animated:YES];

    NSString *latitude = [NSString stringWithFormat:@"Latitude: %f", location.coordinate.latitude, nil];
    NSString *longitude = [NSString stringWithFormat:@"Longitude: %f", location.coordinate.longitude, nil];
    self.latitudeLabel.text = latitude;
    self.longitudeLabel.text = longitude;
    
    [super viewWillAppear:animated]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
