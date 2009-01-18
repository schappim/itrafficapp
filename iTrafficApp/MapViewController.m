//
//  MapViewController.m
//  iTrafficApp
//
//  Created by Joseph Gentle on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "RMMapView.h"
#import "NSString+SBJSON.h"
#import "RMMarkerManager.h"
#import "RMMarker.h"
#import "POIDb.h"

@implementation MapViewController

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*- (void)addMarker:(RMMarker *)marker {
	[[contents projection]latLongToPoint:point]
}*/

- (void)unhideProgress {
	[progress setHidden:NO];
//	[[progress layer] setOpacity:1.0f];
}
- (void)hideProgress {
//	[[progress layer] setOpacity:0.0f];
	[progress setHidden:YES];
}
- (void)setProgress:(NSNumber *)progressInterval {
	float val = [progressInterval floatValue];
	[progress setProgress:val];
}

- (void)addMarkersFromWeb {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[self performSelectorOnMainThread:@selector(unhideProgress) withObject:nil waitUntilDone:NO];	

	NSArray *poi = [[POIDb sharedInstance] allPoints];

	int num = [poi count];
	
	RMMarkerManager *markerManager = [[self mapView] markerManager];
	
	CGImageRef imageRBT = [RMMarker loadPNGFromBundle:@"drop_pin_rbt"];
	CGImageRef imageRedLight = [RMMarker loadPNGFromBundle:@"drop_pin_red-light"];
	CGImageRef imageCameraMobile = [RMMarker loadPNGFromBundle:@"drop_pin_camera_mobile"];
	CGImageRef imageCameraStatic = [RMMarker loadPNGFromBundle:@"drop_pin_camera2"];

	int i = 0;
	for (NSDictionary *dict in poi) {
		CLLocationCoordinate2D position;
		position.latitude = [[dict objectForKey:@"lat"] floatValue];
		position.longitude = [[dict objectForKey:@"lon"] floatValue];
		
//		NSLog(@"adding marker at %f %f", position.latitude, position.longitude);
		RMMarker *marker;
		
		NSString *type = [dict objectForKey:@"type"];
		if ([type isEqualToString:@"speedcam_static"])
			marker = [[RMMarker alloc] initWithCGImage:imageCameraStatic];
		else if ([type isEqualToString:@"speedcam_mobile"])
			marker = [[RMMarker alloc] initWithCGImage:imageCameraMobile];
		else if ([type isEqualToString:@"redlightcam"]
				 || [type isEqualToString:@"speedredcam_static"])
			marker = [[RMMarker alloc] initWithCGImage:imageRedLight];
		else if ([type isEqualToString:@"rbt"])
			marker = [[RMMarker alloc] initWithCGImage:imageRBT];
		else if ([type isEqualToString:@"crash"])
			marker = [[RMMarker alloc] initWithCGImage:imageRBT];
		else {
			NSLog(@"Unrecognised marker type %@", type);
			marker = [[RMMarker alloc] initWithCGImage:imageCameraStatic];
		}
//		if ([type isEqualToString:@"delay"])
//			marker = [[RMMarker alloc] initWithCGImage:image];

		
		[marker setLocation:[[self mapView] latLongToPoint:position]];
//		[markerManager addDefaultMarkerAt:position];
		[markerManager performSelectorOnMainThread:@selector(addMarker:)
										withObject:marker
									 waitUntilDone:YES];
		[marker release];
		
		i++;
		
		float progressInterval = (float)i / num;
		[self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:progressInterval] waitUntilDone:NO];
	}
	[self performSelectorOnMainThread:@selector(hideProgress) withObject:nil waitUntilDone:NO];
	
//	CGImageRelease(image);
	
//	[progressView removeFromSuperview];
	
	[pool drain];
}

- (RMMapView *)mapView {
	return (RMMapView *)[self view];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	RMMapView *mapView = [[RMMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	[mapView setZoom:14.0f];

	progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	[progress setCenter:CGPointMake(160,350)];
	[progress setHidden:YES];
	[mapView addSubview:progress];

//	UITextView *test = [[UITextView alloc] initWithFrame:[mapView frame]];
//	[mapView addSubview:test];
//	[test setText:@"asdfadfasdfasdf"];
	
	[self setView:mapView];
}

// Play an alert if need be.
- (void)checkAlertsAtNewLocation:(CLLocationCoordinate2D)location {
	NSArray *points = [[POIDb sharedInstance] poiInRangeOf:location];
	
	if ([points count] > 0) {
//		SystemSoundID    mySSID;
//		CFURLRef        myURLRef;
//		myURLRef = CFURLCreateWithFileSystemPath (
//												  kCFAllocatorDefault,
//												  CFSTR ("../../ComedyHorns.aif"),
//												  kCFURLPOSIXPathStyle,
//												  FALSE
//												  );
//		
//		// create a system sound ID to represent the sound file
//		OSStatus error = AudioServicesCreateSystemSoundID (myURLRef, &mySSID);
//		
//		// Play the sound file.
//		AudioServicesPlaySystemSound (mySSID);
//		
//		NSString* soundFile = [[NSBundle mainBundle] pathForResource:@"speed_camera" ofType:@"wav"];
//		NSSound* sound = [[NSSound alloc] initWithContentsOfFile:soundFile byReference:YES];
//		[sound 
	}
}

- (void)didReceiveLocationUpdate:(CLLocationCoordinate2D)location speedkmh:(float)speedkmh {
	NSLog(@"didReceiveLocationUpdate %f %f %f", location.latitude, location.longitude, speedkmh);
	[[self mapView] moveToLatLong:location];
	[[[self mapView] markerManager] moveMarker:userMark AtLatLon:location];
	[userMark unhide];
	
	[self checkAlertsAtNewLocation:location];
}

- (void)showUserOptionsDialog {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select Hazard Type"
													message:nil
												   delegate:self 
										  cancelButtonTitle:@"Cancel" 
										  otherButtonTitles:@"Speed Camera", @"Traffic Delay", nil];
	[alert show];
	[alert release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	locHandler = [[LocationHandler alloc] initWithReceiver:self];
	post = [[PostHandler alloc] init];

	userMark = [[RMMarker alloc] initWithCGImage:[RMMarker loadPNGFromBundle:@"Crosshairs"]];
	[userMark setLocation:[[self mapView] XYBounds].origin];
	[userMark setAnchorPoint:CGPointMake(0.5f, 0.5f)];
	[userMark hide];
	[[[self mapView] markerManager] addMarker:userMark];
	
	// Add user feedback options button
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect frame = CGRectMake(200.0, 10.0, 100.0, 30.0);
    button.frame = frame;    // match the button's size with the image size
	
    //[button setBackgroundImage:image forState:UIControlStateNormal];
	[button setTitle:@"New Hazard" forState:UIControlStateNormal];
    
    // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
//    button.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
	
	[self.view addSubview:button];
//	[button release];
	
	
	[self performSelectorInBackground:@selector(addMarkersFromWeb) withObject:nil];
	[RMMapView class];
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
	[self showUserOptionsDialog];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

@end
