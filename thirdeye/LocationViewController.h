//
//  LocationViewController.h
//  thirdeye
//
//  Created by Christopher Neale on 4/23/12.
//  Copyright (c) 2012 New York University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *locationView;
@property (strong, nonatomic) IBOutlet UILabel *dataLabel;

@property (strong, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *latitudeLabel;

@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionField;

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *description;

@property (strong, nonatomic) id dataObject;




- (IBAction)textFieldDoneEditing:(id)sender; 
- (IBAction)backgroundTap:(id)sender;
- (IBAction) createMarker; 
@end


