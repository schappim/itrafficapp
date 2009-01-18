//
//  MapViewController.h
//  iTrafficApp
//
//  Created by Joseph Gentle on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationHandler.h"
#import "PostHandler.h"

@class RMMarker;
@class RMMapView;

@interface MapViewController : UIViewController {
	LocationHandler *locHandler;
	PostHandler *post;
	UIProgressView *progress;
	RMMarker *userMark;
}

@property (nonatomic, readonly) IBOutlet RMMapView *mapView;

@end
