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

- (CLLocationSimulationPoint)makeSimulationPoint:(CLLocationDegrees)latitude 
	:(CLLocationDegrees)longitude
	:(float)speedkmh
	:(float)course; {
	
	CLLocationSimulationPoint sp;
	sp.latitude = latitude;
	sp.longitude = longitude;
	sp.speedkmh = speedkmh;
	sp.course = course;
	return sp;
}

- (void)initSimulationPoints {
	// North Sydney - moving south across bridge - starting Military Rd
	NSInteger i = 0;
	simulationPoints[i] = [self makeSimulationPoint:-33.8277 :151.2145 :60 :180]; ++i;
	simulationPoints[i] = [self makeSimulationPoint:-33.8298 :151.2139 :60 :180]; ++i;
	simulationPoints[i] = [self makeSimulationPoint:-33.8317 :151.2129 :70 :180]; ++i;
	simulationPoints[i] = [self makeSimulationPoint:-33.8334 :151.2119 :70 :180]; ++i;
	simulationPoints[i] = [self makeSimulationPoint:-33.8362 :151.2111 :70 :180]; ++i;
	simulationPoints[i] = [self makeSimulationPoint:-33.8394 :151.2107 :70 :180]; ++i;
	simulationPoints[i] = [self makeSimulationPoint:-33.8421 :151.2109 :70 :180]; ++i;
	simulationPoints[i] = [self makeSimulationPoint:-33.8451 :151.2119 :70 :180]; ++i;
	simulationPoints[i] = [self makeSimulationPoint:-33.8479 :151.2127 :70 :180]; ++i;
	simulationPoints[i] = [self makeSimulationPoint:-33.8502 :151.2124 :70 :180]; ++i;
	simulationPoints[i] = [self makeSimulationPoint:-33.8522 :151.2109 :70 :180]; ++i;
	simulationPoints[i] = [self makeSimulationPoint:-33.8545 :151.2094 :70 :180]; ++i;
	// Have reached end of covered part of bridge	
	// ... add more points here if wanted
	
	numSimulationPoints = i;
}

- (void)runSimulation {
	if (simulationPointIndex < numSimulationPoints) {
		CLLocationSimulationPoint sp;	
		sp = simulationPoints[simulationPointIndex];
		CLLocationCoordinate2D spCoordinate;
		spCoordinate.latitude = sp.latitude;
		spCoordinate.longitude = sp.longitude;
		// Send event
		[receiver didReceiveLocationUpdate:spCoordinate speedkmh:sp.speedkmh course:sp.course];
		// Schedule next simualated event
		simulationPointIndex += 1;		
		[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(runSimulation) userInfo:nil repeats:NO];		
	}
}

- (id)initWithReceiver:(id)idReceiver {
	self = [super init];
	receiver = idReceiver;
	previousTime = [[NSDate alloc] init];
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	locationManager.distanceFilter = kCLDistanceFilterNone; // 100.0;
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
	
	
#if TARGET_IPHONE_SIMULATOR
	// In simulator only reach this point once
	// so ok to init/start similation
	[self initSimulationPoints];
	[self runSimulation];
	return;
	/*
	CLLocationCoordinate2D hereLocation = newLocation.coordinate;
	hereLocation.latitude = -33.8;
	hereLocation.longitude = 151.25;
	hereLocation.latitude = -33.8;
	hereLocation.longitude = 151.25;
	[newLocation release];
	newLocation = [[CLLocation alloc] initWithLatitude:hereLocation.latitude longitude:hereLocation.longitude];	
	*/
	
#endif
	
	NSDate *nowTime = [[NSDate alloc] init];
	float speedkmh;
	if (oldLocation != nil) {
		NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:previousTime];	
		CLLocationDistance distanceTravelled = [newLocation getDistanceFrom:oldLocation];
		speedkmh = distanceTravelled / timeInterval;		
	} else {
		speedkmh = 0.0;
	}
	
	[receiver didReceiveLocationUpdate:newLocation.coordinate speedkmh:speedkmh course:newLocation.course];
	
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
