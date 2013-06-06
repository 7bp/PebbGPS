//
//  NOViewController.m
//  NOPebbleGPS
//
//  Created by Nathan Oates on 31/05/13.
//  Copyright (c) 2013 Nathan Oates. All rights reserved.
//

#import "NOViewController.h"
#import "NOPebbleMessageQueue.h"
#import <PebbleKit/PebbleKit.h>
#import <QuartzCore/QuartzCore.h>

#define MAP_IMG_KEY @(0xEF66)
#define MAX_OUTGOING_SIZE 105

@interface NOViewController () {
  
}

@end


@implementation NOViewController

@synthesize message_queue;

-(void)viewDidLoad {
  [super viewDidLoad];
  
  map.transform = CGAffineTransformMakeScale(2.5f, 2.5f);
  
  _mirrorView = mirrorView32;
  
	// Do any additional setup after loading the view, typically from a nib.
  map.delegate = self;
  map.showsUserLocation = YES;
  [self moveAnnotations];
  message_queue = [[NOPebbleMessageQueue alloc] init];
  
  UITapGestureRecognizer *tap32 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeMirrorSize32)];
  tap32.numberOfTapsRequired = 1;
  tap32.numberOfTouchesRequired = 1;
  mirrorView32.userInteractionEnabled = YES;
  [mirrorView32 addGestureRecognizer:tap32];
  
  UITapGestureRecognizer *tap64 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeMirrorSize64)];
  tap64.numberOfTapsRequired = 1;
  tap64.numberOfTouchesRequired = 1;
  mirrorView64.userInteractionEnabled = YES;
  [mirrorView64 addGestureRecognizer:tap64];
  
  UITapGestureRecognizer *tap128 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeMirrorSize128)];
  tap128.numberOfTapsRequired = 1;
  tap128.numberOfTouchesRequired = 1;
  mirrorView128.userInteractionEnabled = YES;
  [mirrorView128 addGestureRecognizer:tap128];
}

-(void)changeMirrorSize32 {
  _mirrorView = mirrorView32;
  [self createImage:nil];
}

-(void)changeMirrorSize64 {
  _mirrorView = mirrorView64;
  [self createImage:nil];
}

-(void)changeMirrorSize128 {
  _mirrorView = mirrorView128;
  [self createImage:nil];
}

-(void)updateMapLocation:(CLLocation*)newLocation {
  //Later, distance will be set on watch for zoom in/out, for now default to this
  int currentDistance = 400;
  
  //numbers show map zoom. 500,500 = map stretches 500 meters to the North and the South of current location
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (newLocation.coordinate,currentDistance,currentDistance);
  [map setRegion:region animated:NO];
  
  //lauch a timer so the map has time to set itself up
  [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(createImage:) userInfo:nil repeats:NO];
  
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  //lauch a timer so the map has time to set itself up
  [self createImage:nil];
}

-(void)createImage:(NSTimer*)theTimer{
  UIGraphicsBeginImageContextWithOptions(map.bounds.size, YES, 0.0);
  [map.layer renderInContext:UIGraphicsGetCurrentContext()];
  _mirrorView.image = UIGraphicsGetImageFromCurrentImageContext();
  

  UIGraphicsBeginImageContextWithOptions(_mirrorView.bounds.size, YES, 0.0);
  [_mirrorView.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  NSData* imgData = [NOPebbleImage ditheredBitmapFromImage:img withHeight:128 width:128];
  //   NSLog(@"Image datafied");
  
  size_t length = [imgData length];
  uint8_t j = 0;
  for(size_t i = 0; i < length; i += MAX_OUTGOING_SIZE-1) {
    NSMutableData *outgoing = [[NSMutableData alloc] initWithCapacity:MAX_OUTGOING_SIZE];
    [outgoing appendBytes:&j length:1];
    [outgoing appendData:[imgData subdataWithRange:NSMakeRange(i, MIN(MAX_OUTGOING_SIZE-1, length - i))]];
    [message_queue enqueue:@{MAP_IMG_KEY: outgoing}];
    ++j;
  }
}

-(void)moveAnnotations {
  UIView *lView = nil;
  
  for (UIView *subview in map.subviews) {
    if ([subview isKindOfClass:[UILabel class]]) {
      lView = subview;
    }
  }
  lView.frame = CGRectMake(200, 200, lView.frame.size.width, lView.frame.size.height);
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
