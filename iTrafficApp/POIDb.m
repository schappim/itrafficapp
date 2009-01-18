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
	
	for (NSDictionary *dict in array) {
		CLLocationCoordinate2D position;
		position.latitude = [[dict objectForKey:@"lat"] floatValue];
		position.longitude = [[dict objectForKey:@"lon"] floatValue];

		float distance = RMLatLongOrthogonalDistance(location, position);
		
		if (distance < 0.1f)
			[array addObject:dict];
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
