//
//  MapViewController.h
//  thirdeye
//
//  Created by Christopher Neale on 5/7/12.
//  Copyright (c) 2012 New York University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface MapViewController : UIViewController


@property (strong, nonatomic) IBOutlet MKAnnotationView *annotations;
@property (strong, nonatomic) IBOutlet MKMapView *map;


-(MKAnnotationView*)mapView:(MKMapView *) mapView
          viewForAnnotation:(id<MKAnnotation>)annotation;
@end
