//
//  NOPebbleImage.m
//  NOPebbleGPS
//
//  Created by Nathan Oates on 31/05/13.
//  Copyright (c) 2013 Nathan Oates. All rights reserved. Based on code by Katharine Berry (pebbleremote)
//

#import "NOPebbleImage.h"

static inline uint8_t pixelShade(uint8_t* i) {
  return (i[0] + i[1] + i[2]) / 3;
//   return (i[0] * 0.21) + (i[1] * 0.72) + (i[2] * 0.07);
}

static inline size_t offset(size_t width, size_t x, size_t y) {
    return (y * width) + (x); // RGBA
}

#define DIFFUSE_ERROR(a, b) if((a) < width && (b) < height) grey[(b)*width+(a)] = MAX(0, MIN(255, grey[(b)*width+(a)] + (int16_t)(0.125 * (float)err)))

@implementation NOPebbleImage

+ (NSData*)ditheredBitmapFromImage:(UIImage *)image withHeight:(NSUInteger)height width:(NSUInteger)width {
    if(!image) return nil;

    // Resize it
    CGImageRef cg = image.CGImage;
    CGContextRef context = [self newBitmapContextFromImage:cg withHeight:height width:width];
    if(!context) return nil;
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, cg);
    
    // Get a pointer to the data
    uint8_t *bitmap = (uint8_t*)CGBitmapContextGetData(context);
    

    
    
    // A greyscale version
    uint8_t *grey = malloc(width * height);
    
    // And the output
    uint8_t *output = malloc(width * height / 8);
    memset(output, 0, width * height / 8);
    memset(grey, 0, width * height);
    
    // Build up the greyscale image
    for(int i = 0; i < width * height; ++i) {
        grey[i] = pixelShade(&bitmap[i*4]);
    }
    
/*

  */
    CFRelease(context);

    // Convert it to black and white. At the moment, this is using threshold rather than dithering
    for(int y = 0; y < width; ++y) {
        for(int x = 0; x < height; ++x) {
            int i = offset(width, x, y); // RGBA
            uint8_t shade = grey[i];
           // uint8_t actual_shade = shade > 130 ? 255 : 0;
            uint8_t actual_shade = shade > 230 ? 255 : 0;
 //           int16_t err = shade - actual_shade;
            //NSLog(@"err = %d; diff = %d", err, (uint8_t)(0.125 * err));
            grey[i] = actual_shade;
            
 //           // Dithering
 //           DIFFUSE_ERROR(x+1, y);
 //           DIFFUSE_ERROR(x+2, y);
 //           DIFFUSE_ERROR(x-1, y+1);
 //           DIFFUSE_ERROR(x, y+1);
 //           DIFFUSE_ERROR(x+1, y+1);
 //           DIFFUSE_ERROR(x, y+2);
        }
    }
    
    // Put it into the output
    for(size_t i = 0; i < width*height; ++i) {
        output[i/8] |= (grey[i]&1) << ((i%8));
    }
    free(grey);
    NSData *output_data = [NSData dataWithBytes:output length:(width*height/8)];
    free(output);
    return output_data;
}

+ (CGContextRef) newBitmapContextFromImage:(CGImageRef)image withHeight:(NSUInteger)height width:(NSUInteger)width {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if(!colorSpace) return nil;
    
        
    //Create bitmap context
    context = CGBitmapContextCreate(NULL,
                                    width,
                                    height,
                                    8,
                                    width * 4,
                                    colorSpace,
                                    0x00002006);   
   
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

@end