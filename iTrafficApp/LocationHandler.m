//
//  LocationHandler.m
//  iSpeedApp
//
//  Created by Graham Dawson on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationHandler.h"

@implementation LocationHandler

@synthesize isUpdating;

- (id)initWithReceiver:(id)idReceiver {
	self = [super init];
	receiver = idReceiver;
	previousTime = [[NSDate alloc] init];
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	locationManager.distanceFilter = 100.0;
	locationManager.delegate = self;	
	
	isUpdating = NO;
	[self reStartUpdates];
	
	return self;
}

- (void)reStartUpdates {
	if (!isUpdating) {
		if (locationManager.locationServicesEnabled) {
			[locationManager startUpdatingLocation];
			isUpdating = YES;
		}		
	}
}

- (void)suspendUpdates {
	if (isUpdating) {
		[locationManager stopUpdatingLocation];
		isUpdating = NO;
	}
}

// Called when the location is updated
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {	
	
	
//#if TARGET_IPHONE_SIMULATOR
	CLLocationCoordinate2D hereLocation = newLocation.coordinate;
	hereLocation.latitude = -33.8;
	hereLocation.longitude = 151.25;
	[newLocation release];
	newLocation = [[CLLocation alloc] initWithLatitude:hereLocation.latitude longitude:hereLocation.longitude];	
	//newLocation.coordinate = hereLocation;
//#endif
	
	NSDate *nowTime = [[NSDate alloc] init];
	float speedkmh;
	if (oldLocation != nil) {
		NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:previousTime];	
		CLLocationDistance distanceTravelled = [newLocation getDistanceFrom:oldLocation];
		speedkmh = distanceTravelled / timeInterval;		
	} else {
		speedkmh = 0.0;
	}
	
	[receiver didReceiveLocationUpdate:newLocation.coordinate speedkmh:speedkmh];
	
	[previousTime release];
	previousTime = [nowTime copy];
	[nowTime release];
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	[locationManager stopUpdatingLocation];	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Problem" message:@"Sorry! Unable to obtain your location. Try again later."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

- (void)dealloc {
	[locationManager stopUpdatingLocation];
	[locationManager release];
	[previousTime release];
	[super dealloc];
}

@end
