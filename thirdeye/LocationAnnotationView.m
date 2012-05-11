//
//  LocationAnnotationView.m
//  thirdeye
//
//  Created by Christopher Neale on 5/7/12.
//  Copyright (c) 2012 New York University. All rights reserved.
//

#import "LocationAnnotationView.h"

@implementation LocationAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.draggable = true;
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
