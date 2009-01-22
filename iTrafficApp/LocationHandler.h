//
//  LocationHandler.h
//  iSpeedApp
//
//  Created by Graham Dawson on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef struct {
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
	float speedkmh;
	float course;
} CLLocationSimulationPoint;

@protocol LocationHandlerProtocol
-(void)didReceiveLocationUpdate:(CLLocationCoordinate2D)location speedkmh:(float)speedkmh course:(float)course;
@end

@interface LocationHandler : NSObject <CLLocationManagerDelegate> {
	id receiver;
@private
	CLLocationManager *locationManager;
	NSDate *previousTime;
	BOOL isUpdating;
	// For simulation only
	CLLocationSimulationPoint simulationPoints[100];
	NSInteger numSimulationPoints;
	NSInteger simulationPointIndex;
}

- (id)initWithReceiver:(id)idReceiver;
- (void)suspendUpdates;
- (void)reStartUpdates;

@property (readonly) BOOL isUpdating;

@end
