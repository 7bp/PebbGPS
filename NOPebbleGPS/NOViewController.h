//
//  NOViewController.h
//  NOPebbleGPS
//
//  Created by Nathan Oates on 31/05/13.
//  Copyright (c) 2013 Nathan Oates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "NOPebbleImage.h"
#import "NOPebbleMessageQueue.h"

@interface NOViewController : UIViewController <MKMapViewDelegate> {
  __weak IBOutlet MKMapView *map;
  __weak IBOutlet UIImageView *mirrorView32;
  __weak IBOutlet UIImageView *mirrorView64;
  __weak IBOutlet UIImageView *mirrorView128;
}
@property(nonatomic, retain) NOPebbleMessageQueue *message_queue;
@property(assign) UIImageView *mirrorView;

-(void)updateMapLocation:(CLLocation*)newLocation;
-(void)createImage:(NSTimer*)theTimer;
  
  @end
