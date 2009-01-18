//
//  iTrafficAppAppDelegate.m
//  iTrafficApp
//
//  Created by Joseph Gentle on 17/01/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iTrafficAppAppDelegate.h"
#import "RootViewController.h"

@implementation iTrafficAppAppDelegate


@synthesize window;
@synthesize rootViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
	
	[application setIdleTimerDisabled:YES];
}


- (void)dealloc {
    [rootViewController release];
    [window release];
    [super dealloc];
}

@end
