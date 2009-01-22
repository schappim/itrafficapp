//
//  POIDb.m
//  iTrafficApp
//
//  Created by Joseph Gentle on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "POIDb.h"
#import "NSString+SBJSON.h"
#import "RMLatLong.h"

static POIDb *db;

@implementation POIDb

- (id)init {
	if (![super init])
		return nil;
	
	return self;
}

- (NSArray *)poi {
	if (poi == nil){
		poi = [[NSMutableArray alloc] init];
		
		NSString *json = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.littlebirdit.com/is/json.php"]];
		[poi addObjectsFromArray:[json JSONValue]];
		
//		NSString *mutableJson = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.littlebirdit.com/is/mobile.php"]];
//		[poi addObjectsFromArray:[mutableJson JSONValue]];
	}
	NSLog(@"loaded %d points", [poi count]);
	return poi;
}

- (NSArray *)allPoints {
	return [self poi];
	
	return poi;
}

- (NSArray *)poiInRangeOf:(CLLocationCoordinate2D)location {
	NSMutableArray *array = [NSMutableArray array];
	
	//for (NSDictionary *dict in array) {
	for (NSDictionary *dict in poi) {
		CLLocationCoordinate2D position;
		position.latitude = [[dict objectForKey:@"lat"] floatValue];
		position.longitude = [[dict objectForKey:@"lon"] floatValue];

		// This returns pseudo-distance in degrees - 1 deg is approx. 100km
		float distance = RMLatLongOrthogonalDistance(location, position);
		
		if (distance < 0.005) {
			[array addObject:dict];
			NSLog(@"Proximate hazard - lat:%f, long:%f, dist:%f", position.latitude, position.longitude, distance);
		}
	}
	
	return array;
}

+ (POIDb *)sharedInstance {
	if (db == nil) {
		db = [[POIDb alloc] init];
	}
	
	return db;
}

@end
