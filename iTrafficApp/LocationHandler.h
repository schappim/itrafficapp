//
//  LocationHandler.h
//  iSpeedApp
//
//  Created by Graham Dawson on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationHandlerProtocol
-(void)didReceiveLocationUpdate:(CLLocationCoordinate2D)location speedkmh:(float)speedkmh;
@end

@interface LocationHandler : NSObject <CLLocationManagerDelegate> {
	id receiver;
@private
	CLLocationManager *locationManager;
	NSDate *previousTime;
	BOOL isUpdating;
}

- (id)initWithReceiver:(id)idReceiver;
- (void)suspendUpdates;
- (void)reStartUpdates;

@property (readonly) BOOL isUpdating;

@end
