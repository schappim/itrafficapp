//
//  PostHandler.h
//  iSpeedApp
//
//  Created by Graham Dawson on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PostHandler : NSObject {
	id receivedData;
}

- (void)postIncident:(NSString *)type location:(CLLocationCoordinate2D)location;

@end
