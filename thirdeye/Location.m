//
//  Location.m
//  thirdeye
//
//  Created by Christopher Neale on 5/2/12.
//  Copyright (c) 2012 New York University. All rights reserved.
//

#import "Location.h"


@implementation Location

@dynamic title, content, creationDate,longitude,latitude,accuracy,active;

-(CLLocationCoordinate2D) coordinate
{
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

-(void)setCoordinate:(CLLocationCoordinate2D)coord
{
    self.coordinate = coord; 
    [self setLatitude:[NSNumber numberWithDouble:coord.latitude]];
    [self setLongitude:[NSNumber numberWithDouble:coord.longitude]];
}
@synthesize coordinate;
@end
