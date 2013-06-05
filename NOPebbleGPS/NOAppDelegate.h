//
//  NOAppDelegate.h
//  NOPebbleGPS
//
//  Created by Nathan Oates on 31/05/13.
//  Copyright (c) 2013 Nathan Oates. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NOViewController;

@interface NOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NOViewController *viewController;

@end
