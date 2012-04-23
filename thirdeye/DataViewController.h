//
//  DataViewController.h
//  thirdeye
//
//  Created by Kathryn Saxton on 4/23/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;

@end
