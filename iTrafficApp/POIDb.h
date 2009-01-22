//
//  POIDb.h
//  iTrafficApp
//
//  Created by Joseph Gentle on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationHandler.h"
#import "FMDatabase.h"

@interface POIDb : NSObject {
	FMDatabase *database;
	
	// TEMP
	NSMutableArray *poi;
}

- (NSArray *)allPoints;
- (NSArray *)poiInRangeOf:(CLLocationCoordinate2D)location radiusMetres:(float)radius;

+ (POIDb *)sharedInstance;

@end
