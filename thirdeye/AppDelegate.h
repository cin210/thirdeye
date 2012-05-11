//
//  AppDelegate.h
//  thirdeye
//
//  Created by Christopher Neale on 4/23/12.
//  Copyright (c) 2012 New York University. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import <PanicARLib/PanicARLib.h> 

@class ARController; 
@class LocationViewController; 

// include the ARControllerDelegate Protocol to receive events from the ARController
@interface AppDelegate : NSObject <UIApplicationDelegate, ARControllerDelegate, UITabBarControllerDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UINavigationControllerDelegate, UIPageViewControllerDelegate> {
    
    UIWindow *window; 
    UITabBarController *tabBarController;
    
    IBOutlet UITableViewController  *tableViewController; 
    IBOutlet UINavigationController *navigationController; 
    UITableView *tableView;
    UITabBarItem *arBarItem;
    BOOL arIsVisible;
    
    
    // Core data stuff
    UIBarButtonItem *addButton;  
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    
    LocationViewController *locationViewController; 
	ARController* m_ARController; // the AR controller instance of the app
}


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
 
@property (strong, nonatomic) NSMutableArray *listOfLocations;
@property (nonatomic, retain) UIBarButtonItem *addButton;

// UI
@property (nonatomic, retain) IBOutlet UIWindow* window;
@property (nonatomic, retain) IBOutlet UITabBarController* tabBarController; 

@property (nonatomic, retain) ARController* the_ARController; 
@property (nonatomic, retain) IBOutlet UINavigationController* navigationController; 

@property (nonatomic, retain) IBOutlet LocationViewController* locationViewController;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UITabBarItem *arBarItem;



// AR functionality
- (IBAction) addMarker; //used to create a new marker
- (IBAction) addMarkerWithName:(NSString *)name Description:(NSString *)description; //used to create a new marker

- (void) createAR;
- (void) createMarkers;
- (void) showAR;
- (BOOL) checkForAR:(BOOL)showErrors;

// for a button
- (NSString*)accuracyRank:(float)accuracyValue;
- (IBAction)webButton_click;

//coredata 

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
