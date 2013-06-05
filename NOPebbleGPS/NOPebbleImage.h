//
//  NOPebbleImage.h
//  NOPebbleGPS
//
//  Created by Nathan Oates on 31/05/13.
//  Copyright (c) 2013 Nathan Oates. All rights reserved. Based on code by Katharine Berry (pebbleremote)
//

#import <Foundation/Foundation.h>

@interface NOPebbleImage : NSObject

+ (NSData*)ditheredBitmapFromImage:(UIImage *)image withHeight:(NSUInteger)height width:(NSUInteger)width;

@end

