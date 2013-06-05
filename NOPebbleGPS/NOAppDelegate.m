//
//  NOAppDelegate.m
//  NOPebbleGPS
//
//  Created by Nathan Oates on 31/05/13.
//  Copyright (c) 2013 Nathan Oates. All rights reserved.
//

#import "NOAppDelegate.h"
#import <PebbleKit/PebbleKit.h>
#import <CoreLocation/CoreLocation.h>


#import "NOViewController.h"
@interface NOAppDelegate () <PBPebbleCentralDelegate, CLLocationManagerDelegate>
@end

@implementation NOAppDelegate {
    PBWatch *targetWatch;
    CLLocationManager *locationMan;
}

- (void)refreshAction:(id)sender {
    if (targetWatch == nil || [targetWatch isConnected] == NO) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"No connected watch!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
        
        //do other stuff, send update?
    }
}

- (void)setTargetWatch:(PBWatch*)watch {
    targetWatch = watch;
    
    // Test if the Pebble's firmware supports AppMessages / Weather:
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            // Configure our communications channel to target the weather app:
            // See demos/feature_app_messages/weather.c in the native watch app SDK for the same definition on the watch's end:
            uint8_t bytes[] = {0x1A, 0x1A, 0x0E, 0xA3, 0x15, 0x9B, 0x41, 0x97, 0x94, 0x37, 0x16, 0x24, 0xDD, 0x2F, 0xB0, 0x65};
            NSData *uuid = [NSData dataWithBytes:bytes length:sizeof(bytes)];
            [watch appMessagesSetUUID:uuid];
            self.viewController.message_queue.watch = watch;
            NSLog(@"Yay! supports AppMessages");
            
  //          NSString *message = [NSString stringWithFormat:@"Yay! %@ supports AppMessages :D", [watch name]];
    //        [[[UIAlertView alloc] initWithTitle:@"Connected!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            NSLog(@"Nope! Not support AppMessages");
      //      NSString *message = [NSString stringWithFormat:@"Blegh... %@ does NOT support AppMessages :'(", [watch name]];
        //    [[[UIAlertView alloc] initWithTitle:@"Connected..." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[NOViewController alloc] initWithNibName:@"NOViewController_iPhone" bundle:nil];
  //  }
  //  else {
  //      self.viewController = [[NOViewController alloc] initWithNibName:@"NOViewController_iPad" bundle:nil];
  //  }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
 
    // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    
    // Initialize with the last connected watch:
    [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
  
    locationMan = [[CLLocationManager alloc] init];
    locationMan.distanceFilter = 5.0 * 10.0; // Move at least 50m until next location event is generated
    locationMan.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationMan.delegate = self;
    [locationMan startUpdatingLocation];
    
    return YES;
}

/*
 *  PBPebbleCentral delegate methods
 */

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    [self setTargetWatch:watch];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    [[[UIAlertView alloc] initWithTitle:@"Disconnected!" message:[watch name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (targetWatch == watch || [watch isEqual:targetWatch]) {
        [self setTargetWatch:nil];
    }
}

/*
 *  CLLocationManagerDelegate
 */

// iOS 5 and earlier:
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"New Location: %@", newLocation);
    [self.viewController updateMapLocation:newLocation];
}

// iOS 6 and later:
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *lastLocation = [locations lastObject];
    NSLog(@"New (last) Location: %@", lastLocation);
    [self.viewController updateMapLocation:lastLocation];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //this will change later once background working. For now may as well stop the location tracking
    [locationMan stopUpdatingLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [locationMan startUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [locationMan stopUpdatingLocation];
    [targetWatch closeSession:nil];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
