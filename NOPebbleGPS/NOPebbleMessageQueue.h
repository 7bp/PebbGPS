//
//  NOPebbleQueue.h
//  NOPebbleGPS
//
//  Created by Nathan Oates on 1/06/13.
//  Copyright (c) 2013 Nathan Oates. All rights reserved. Based on code by Katharine Berry (pebbleremote)
//

#import <Foundation/Foundation.h>

@class PBWatch;

@interface NOPebbleMessageQueue : NSObject {
    NSMutableArray *queue;
    BOOL has_active_request;
}

- (void)enqueue:(NSDictionary*)message;

@property (nonatomic, retain) PBWatch* watch;

@end

