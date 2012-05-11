//
//  Location.h
//  thirdeye
//
//  Created by Chris Neale on 5/2/12.
//  Copyright (c) 2012 New York University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MApKit/MapKit.h>

@interface Location : NSManagedObject <MKAnnotation>


@property (nonatomic, retain, getter=isActive) NSNumber * active;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * accuracy;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@end
