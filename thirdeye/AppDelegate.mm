//
//  AppDelegate.m
//  thirdeye
//
//  Created by Christopher Neale on 4/23/12. Copyright Dome 2012. All Rights reserved
//  AR implementation created by Andreas Zeitler on 9/1/11. Copyright doPanic 2011. All rights reserved. 

#import "AppDelegate.h" 

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif
 
#import <CoreData/CoreData.h>
#include "Location.h"
#include "LocationViewController.h" 





@implementation AppDelegate
 
 
// not really used but what the heck why not keep these jokers around
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
} 
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
} 
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@synthesize addButton;

@synthesize listOfLocations;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize window;
@synthesize tableView;
@synthesize tabBarController; 
@synthesize locationViewController;
@synthesize arBarItem; 
@synthesize the_ARController;
// application delegate method  
- (void)applicationDidFinishLaunching:(UIApplication *)application { 
    tabBarController.delegate = self;  
    tableView.delegate = self;  
     
    NSManagedObjectContext *context = [self managedObjectContext];  
    __managedObjectContext = context;
    self.window.rootViewController = tabBarController;
    LocationViewController *viewcontroller = [[LocationViewController alloc] init];
    navigationController = [[UINavigationController alloc] initWithRootViewController:viewcontroller];    
    navigationController.delegate = self;
    
    // [self.window addSubview:tabBarController.view];
    
	[window makeKeyAndVisible];
      
    //init the coredata stuff
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:context]; 
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors]; 
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Woops"
                                                        message:@"Failed to load existing points. Try reloading the app."
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OK Button", @"OK") 
                                              otherButtonTitles:nil, nil];
        [alert show]; 
    }
    NSLog(@"beginning with locations");
    
    // create ARController and Markers. Hide AR screen if it isn't available 
    [self setListOfLocations:mutableFetchResults]; 
    [self createAR];
	[self createMarkers];
    if ([self checkForAR:YES]) [self showAR]; 
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
	[m_ARController suspendToBackground];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground");
    [self checkForAR:NO];
	[m_ARController resumeFromBackground];
}

 


// standard dealloc of the delegate (for version without reference counting)
/*
- (void)dealloc {
	if (m_ARController != nil) [m_ARController release];
    self.listOfPoints = nil;
	[window release];
	[super dealloc];
}
*/

// check if AR is available, show error if it's not and set bar item
- (BOOL) checkForAR:(BOOL)showErrors {
    BOOL supportsAR = [ARController deviceSupportsAR];
    BOOL supportsLocations = [ARController locationServicesAvailable];
    BOOL result = supportsLocations && supportsAR;
    
    arBarItem.enabled = result;
    if (!result) {
        [tabBarController setSelectedIndex:1];
    }
    
    if (showErrors) {
        if (!supportsAR) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AR not supported"
                                                            message:@"This device does not support Augmented Reality"
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"OK Button", @"OK") 
                                                  otherButtonTitles:nil, nil];
            [alert show]; 
        }
        
        if (!supportsLocations) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Denied Title", @"Error")
                                                            message:NSLocalizedString(@"Location Denied Message", @"GPS not available")
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"OK Button", @"OK") 
                                                  otherButtonTitles:nil, nil];
            [alert show]; 
        }
    }
    
    return result;
}

// create the ARController
- (void) createAR {
	//setup ARController properties
    [ARController setAPIKey:@"1c8ad7821f6afc9ce3ee4ba6"];
	[ARController setEnableCameraView:YES];
	[ARController setEnableRadar:YES];
	[ARController setEnableInteraction:YES];
	[ARController setEnableLoadingView:YES]; // enable loading view, call has no effect on iOS 5 (not supported yet)
	[ARController setEnableAccelerometer:YES];
	[ARController setEnableAutoswitchToRadar:YES];
	[ARController setEnableViewOrientationUpdate:YES];
	[ARController setFadeInAnim:UIViewAnimationTransitionCurlDown];
	[ARController setFadeOutAnim:UIViewAnimationTransitionCurlUp];
	[ARController setCameraTint:0 g:0 b:0 a:0];
	[ARController setCameraTransform:1.25 y:1.25];
    [ARController setRange:5 Maximum:-1];
    [ARController setRadarPosition:0 y:-24];
    
	
	//create ARController
	m_ARController = [[ARController alloc] initWithNibName:@"ARController" bundle:nil delegate:self];
 	//[[tabBarController.viewControllers objectAtIndex:0] setView:nil];
	self.the_ARController = m_ARController;
#if (TARGET_IPHONE_SIMULATOR)
	// returns nil if AR not available on device
	if (m_ARController) {
		// simulator testing coordinates
		m_ARController.lastLocation = [[CLLocation alloc] initWithLatitude:49.009860 longitude:12.108049];
	}
#endif
    
    arBarItem.enabled = [ARController locationServicesAvailable];
}

// create a few test markers
- (void) createMarkers { 
    NSLog(@"initializing markers: ");
    for (int y = 0; y < [self.listOfLocations count]; y++) {
        
        Location *tempLocation = [self.listOfLocations objectAtIndex:y];
        double latitude = [[tempLocation latitude] doubleValue]; 
        double longitude = [[tempLocation longitude] doubleValue]; 
        ARMarker* newMarker = [[ARMarker alloc] initWithTitle:[tempLocation title]
                                                contentOrNil:[tempLocation content]]; 
        
        NSLog(@"\n added marker number with distance %f",newMarker.distance);
        [m_ARController addMarkerAtLocation: newMarker atLocation:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] ];
    }
    
    // first: setup a new marker with title and content
    //ARMarker* newMarker = [[ARMarker alloc] initWithTitle:@"Rome" contentOrNil:@"Italy"];
    
    // second: add the marker to the ARController using the addMarkerAtLocation method
    // pass the geolocation (latitude, longitude) that specifies where the marker should be located
    // WARNING: use double-precision coordinates whenever possible (the following coordinates are from Google Maps which only provides 8-9 digit coordinates
	//[m_ARController addMarkerAtLocation: newMarker atLocation:[[CLLocation alloc] initWithLatitude:41.890156 longitude:12.492304] ];
    
    
    // add a second marker
    //newMarker = [[ARMarker alloc] initWithTitle:@"Berlin" contentOrNil:@"Germany"];
    //[m_ARController addMarkerAtLocation:newMarker atLocation:[[CLLocation alloc] initWithLatitude:52.523402 longitude:13.41141]];
    
    // add a third marker, this time allocation of a new marker and adding to the ARController are wrapped up in one line
	//[m_ARController addMarkerAtLocation:[[ARMarker alloc] initWithTitle:@"London" contentOrNil:@"United Kingdom"] atLocation:[[CLLocation alloc] initWithLatitude:51.500141 longitude:-0.126257] ];
    
    /*newMarker = [[ARMarker alloc] initAs3DObject:@"msh_box.obj" 
     texture:@"59-info.png" 
     position:[ARVector vectorWithCoords:0 Y:0 Z:0] 
     rotation:[ARVector vectorWithCoords:0 Y:0 Z:0] 
     scale:1];*/
}

// display the ARView in the tab bar (non-modal)
- (void) showAR {
    // on DEVICE: show error if device does not support AR functionality
    // AR is not supported if either camera or compass is not available
#if !(TARGET_IPHONE_SIMULATOR)
    if (![ARController deviceSupportsAR]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No AR Error Title", @"No AR Support")
                                                        message:NSLocalizedString(@"No AR Error Message", @"This device does not support AR functionality!") 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK Button", @"OK") 
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
#endif
    
    // check if ARController instance is valid
    if (m_ARController == nil) {
        NSLog(@"No ARController available!");
        return;
    }
    
    // show AR Controller in tab bar by assigning the ARView to the first view controller of the tab bar
    [[tabBarController.viewControllers objectAtIndex:0] setView:m_ARController.view];
    // now tell the ARController to become visbiel in a non-modal way while keeping the status bar visible
    // NOTE: the camera feed will mess with the status bar's visibility while being loaded, so far there is no way to avoid that (iOS SDK weakness)
    [m_ARController showController:NO showStatusBar:YES];
    // when showing the ARView non-modal the viewport has to be set each time it becomes visible in order to avoid positioning and resizing problems
    [m_ARController setViewport:CGRectMake(0, 0, 320, 411)];
    
    NSLog(@"ARView selected in TabBar");
}
- (IBAction)addMarkerWithName:(NSString *)name Description:(NSString *)description { 
    
    NSLog(@"Creating a marker with name %@ and description %@", name, description);
    //get current location
    CLLocation *location = [m_ARController.locationManager location];
    if (!location) {
        return;
    } 
    if(m_ARController.lastLocationAccuracy > 50){
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"The GPS accuracy of this location is very poor."
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"OK Button", @"Cancel") 
                                          otherButtonTitles:NSLocalizedString(@"OK Button", @"Save it Anyway") , nil];
    [alert show]; 
    }
    
    // create a new Location object which will be what is stored in coredata
    Location *newLocation =  (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:[self managedObjectContext]];
    
    CLLocationCoordinate2D coord = location.coordinate;
    
    [newLocation setLatitude:[NSNumber numberWithDouble:coord.latitude]];
    [newLocation setLongitude:[NSNumber numberWithDouble:coord.longitude]];
    [newLocation setCreationDate:[NSDate date]];
    [newLocation setTitle: name]; 
    [newLocation setContent: description];
    [newLocation setAccuracy: [NSNumber numberWithFloat: m_ARController.lastLocationAccuracy]];
    
    // create an ARMarker object to put into the table
    ARMarker* newMarker = [[ARMarker alloc] initWithTitle:name contentOrNil:description];
    newMarker.location = location;    
    [m_ARController addMarker: newMarker];
    
    NSError *error = nil;
    if (![__managedObjectContext save:&error]) {
        // Handle the error.
    } 
    
    [listOfLocations insertObject:newLocation atIndex:0]; 
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

- (IBAction)addMarker { 
    
    //get current location
    CLLocation *location = [m_ARController.locationManager location];
    if (!location) {
        return;
    } 
    // create a new Location object which will be what is stored in coredata
    Location *newLocation =  (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:[self managedObjectContext]];
    
    CLLocationCoordinate2D coord = location.coordinate;
    
      [newLocation setLatitude:[NSNumber numberWithDouble:coord.latitude]];
      [newLocation setLongitude:[NSNumber numberWithDouble:coord.longitude]];
      [newLocation setCreationDate:[NSDate date]];
      [newLocation setTitle: @"lol"];
      [newLocation setAccuracy: [NSNumber numberWithFloat: m_ARController.lastLocationAccuracy]];
    
    // create an ARMarker object to put into the table
    ARMarker* newMarker = [[ARMarker alloc] initWithTitle:newLocation.title contentOrNil:newLocation.content];
     
    // CLLocationCoordinate2D coordinate = [location coordinate];
    newMarker.location = location;    
    [m_ARController addMarker: newMarker];
    
    NSError *error = nil;
    if (![__managedObjectContext save:&error]) {
        // Handle the error.
    } 
    
    [listOfLocations insertObject:newLocation atIndex:0]; 
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
     
}

#pragma mark -
#pragma mark AR Callbacks

// marker interaction delegate
// called when the AR view is tapped
// marker is the marker that was tapped, or nil if none was hit
- (void) arDidTapMarker:(ARMarker*)marker {
	if (marker != nil) {
		marker.touchDownColorR = 1;
		marker.touchDownColorG = 0.5;
		marker.touchDownColorB = 0.5;
		marker.touchDownColorA = 1;
		marker.touchDownScale = 1.25;
		
		NSLog(@"markerClicked: %@", marker.title);
		m_ARController.infoLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@", marker.title, marker.content];
	}
	else m_ARController.infoLabel.text = [[NSString alloc] initWithFormat:@""];
}

// update callback, fills the info label of the ARController with signal quality information
- (void) arDidUpdateLocation {
    if (m_ARController.lastLocation == nil) {
        m_ARController.infoLabel.text = @"could not retrieve location";
        m_ARController.infoLabel.textColor = [UIColor redColor];
    }
    else { 
        m_ARController.infoLabel.text = [NSString stringWithFormat:@"GPS accuracy rating: %@", 
                                                      [self accuracyRank: m_ARController.lastLocationAccuracy]];
        m_ARController.infoLabel.textColor = [UIColor whiteColor];
    }
}

-(NSString*)accuracyRank:(float)accuracyValue{
    if(accuracyValue < 6){
        return @"Best";
    }
    else if(accuracyValue < 10){
        return @"Good";
    }
    else if(accuracyValue < 20){
        return @"Okay";
    }
    else if(accuracyValue < 30){
        return @"Poor";
    }
    else if(accuracyValue < 50){
        return @"Bad"; 
    }
    else if(accuracyValue < 100){
        return @"Very Bad";  
    }
    else if(accuracyValue > 100) {
        return @"Embarassingly Bad"; 
    }
    return @"Unknown";
}
// orientation update callback: updates orientation and positioning of radar screen
- (void) arDidChangeOrientation:(UIDeviceOrientation)orientation radarOrientation:(UIDeviceOrientation)radarOrientation {
    if (!m_ARController.isVisible || (m_ARController.isVisible && !m_ARController.isModalView)) {
        if (radarOrientation == UIDeviceOrientationPortrait) [ARController setRadarPosition:0 y:-11];
        else if (radarOrientation == UIDeviceOrientationPortraitUpsideDown) [ARController setRadarPosition:0 y:11];
        else if (radarOrientation == UIDeviceOrientationFaceUp) [ARController setRadarPosition:0 y:-11];
        else if (radarOrientation == UIDeviceOrientationLandscapeLeft) [ARController setRadarPosition:-11 y:0];
        else if (radarOrientation == UIDeviceOrientationLandscapeRight) [ARController setRadarPosition:11 y:0];
    }
}

- (void) arDidReceiveErrorCode:(int)code {
    
}



#pragma mark -
#pragma mark UI Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listOfLocations count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    } 
    static NSString *CellIdentifier = @"Cell"; 
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]  
                 initWithStyle:UITableViewCellStyleDefault   
                 reuseIdentifier:CellIdentifier];
    } 
    // Set up the cell... 
    Location *location = [listOfLocations objectAtIndex:indexPath.row];  
    NSString *cellTitle = location.title;
    
    cell.textLabel.text = cellTitle; 
    cell.detailTextLabel.text = [dateFormatter stringFromDate:[location creationDate]];
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath { 
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSManagedObjectContext *context = __managedObjectContext;
        NSLog(@"Deleted at row %d", indexPath.row);
        Location *location = [self.listOfLocations  objectAtIndex:indexPath.row];
        
        //kill it with fire
        [self.listOfLocations removeObject:location];
        [m_ARController.markers removeObjectAtIndex:indexPath.row];
        [context deleteObject:location];
        
        NSError *error = nil;
         if (![__managedObjectContext save:&error]) {
             // Handle the error.
         } 
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }    
}
//The navigation controller is within the tabViewController. When the table row is clicked, navigate deeper

/* Add in to load row data when a row is clicked
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   LocationViewController *locationPage = [[LocationViewController alloc] initWithNibName:@"locationViewNib" bundle:nil];
    
    NSLog(@"selected row %i", indexPath.row);
    
   locationPage.dataObject = [listOfLocations objectAtIndex:indexPath.row]; 
        
   [self.navigationController pushViewController:locationPage animated:YES]; 
}
*/


// tab bar delegate method, switches the views displayed by the app
- (void)tabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController {
	if ([tabBarController.viewControllers indexOfObject:viewController] == 0) {
		[self showAR];
        arIsVisible = YES;
        
	}
	else {
		[[tabBarController.viewControllers objectAtIndex:0] setView:nil];
		[m_ARController hideController];
        arIsVisible = NO;    
        
	}
	
}

// about dialog weblink action
- (IBAction) webButton_click {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.dopanic.com/ar"]];
}





#pragma mark -
#pragma mark Core Data Methods
- (NSManagedObjectContext *)managedObjectContext
{
    
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    } 
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"thirdeye" withExtension:@"momd"]; 
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
     
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{    

    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    } 
    NSURL *storeURL =  [self applicationDocumentsDirectory] ; 
     
    storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"thirdeye.sqlite"];
     
    NSError *error = nil; 
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
     
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) { 
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
     
    return __persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
