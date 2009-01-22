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
#import "SoundEffect.h"

@implementation MapViewController

NSString *const kStringSpeedCameraStatic = @"speedcam_static";
NSString *const kStringSpeedCameraMobile = @"speedcam_mobile";
NSString *const kStringRedLightCam = @"redlightcam";
NSString *const kStringSpeedRedLightCam = @"speedredcam_static";
NSString *const kStringRBT = @"rbt";
NSString *const kStringCrash = @"crash";
NSString *const kStringDelay = @"delay";

// These get values assigned in loadSounds method
NSInteger kSoundSpeedCamera;
NSInteger kSoundRedLightCamera;
NSInteger kSoundTrafficDelay;
NSInteger kSoundTrafficHazard;
NSInteger kSoundRBT;

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
		if ([type isEqualToString:kStringSpeedCameraStatic])
			marker = [[RMMarker alloc] initWithCGImage:imageCameraStatic];
		else if ([type isEqualToString:kStringSpeedCameraMobile])
			marker = [[RMMarker alloc] initWithCGImage:imageCameraMobile];
		else if ([type isEqualToString:kStringRedLightCam]
				 || [type isEqualToString:kStringSpeedRedLightCam])
			marker = [[RMMarker alloc] initWithCGImage:imageRedLight];
		else if ([type isEqualToString:kStringRBT])
			marker = [[RMMarker alloc] initWithCGImage:imageRBT];
		else if ([type isEqualToString:kStringCrash])
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

- (void)loadSounds {
	soundEffects = [[NSMutableArray alloc] initWithCapacity:10];
	SoundEffect *thisSoundEffect;
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *soundFile;
	NSString *soundFileName;
	
	soundFileName = @"speed_camera";
	soundFile = [mainBundle pathForResource:soundFileName ofType:@"wav"];
	thisSoundEffect = [[SoundEffect alloc] initWithContentsOfFile:soundFile];
	[soundEffects addObject:thisSoundEffect];
	kSoundSpeedCamera = [soundEffects count]-1;
	[thisSoundEffect release];
	
	soundFileName = @"red_light";
	soundFile = [mainBundle pathForResource:soundFileName ofType:@"wav"];
	thisSoundEffect = [[SoundEffect alloc] initWithContentsOfFile:soundFile];
	[soundEffects addObject:thisSoundEffect];
	kSoundRedLightCamera = [soundEffects count]-1;
	[thisSoundEffect release];
	
	soundFileName = @"delay_expected";
	soundFile = [mainBundle pathForResource:soundFileName ofType:@"wav"];
	thisSoundEffect = [[SoundEffect alloc] initWithContentsOfFile:soundFile];
	[soundEffects addObject:thisSoundEffect];
	kSoundTrafficDelay = [soundEffects count]-1;
	[thisSoundEffect release];
	
	soundFileName = @"traffic_hazard";
	soundFile = [mainBundle pathForResource:soundFileName ofType:@"wav"];
	thisSoundEffect = [[SoundEffect alloc] initWithContentsOfFile:soundFile];
	[soundEffects addObject:thisSoundEffect];
	kSoundTrafficHazard = [soundEffects count]-1;
	[thisSoundEffect release];
	
	soundFileName = @"rbt";
	soundFile = [mainBundle pathForResource:soundFileName ofType:@"wav"];
	thisSoundEffect = [[SoundEffect alloc] initWithContentsOfFile:soundFile];
	[soundEffects addObject:thisSoundEffect];
	kSoundRBT = [soundEffects count]-1;
	[thisSoundEffect release];
		
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
	
	[self loadSounds];
	
	// TODO - initialise these from cached map location??
	latestLocation.latitude = -1.0;
	latestLocation.longitude = -1.0;
	latestSpeedkmh = -1.0;
	latestCourse = -1.0; 
}

// Play an alert if need be.
- (void)checkAlertsAtNewLocation:(CLLocationCoordinate2D)location {
	NSArray *points = [[POIDb sharedInstance] poiInRangeOf:location radiusMetres:500.0];
	
	if ([points count] > 0) {
		// Need to pick sound for correct point/marker type here....		
		// For now just use first point (may be multiple)
		NSInteger iPoint;
		for (iPoint=0; iPoint<[points count]; ++iPoint) {
			NSDictionary *thisPoint = [points objectAtIndex:0];	
			// Need to check if approaching/receding & ignore if receding
			CLLocationCoordinate2D position;
			position.latitude = [[thisPoint objectForKey:@"lat"] floatValue];
			position.longitude = [[thisPoint objectForKey:@"lon"] floatValue];
			
			float directionToMarker = [LocationHandler courseFromPoint:latestLocation toPoint:position];
			// Compare with current direction of travel - reduce to range +/- 180
			float directionDif = fmod((directionToMarker - latestCourse + 180.0), 360.0) - 180.0;
			NSLog(@"directionDif: %f", directionDif);
			if (fabs(directionDif) < 90) {			
				NSString *type = [thisPoint objectForKey:@"type"];
				NSLog(@"type %@", type);
				NSInteger soundIndex;
				if (([type isEqualToString:kStringSpeedCameraStatic]) 
					|| ([type isEqualToString:kStringSpeedCameraMobile])
					|| ([type isEqualToString:kStringSpeedRedLightCam])) {
					soundIndex = kSoundSpeedCamera;
				} else if ([type isEqualToString:kStringRedLightCam]) {
					soundIndex = kSoundRedLightCamera;
				} else if ([type isEqualToString:kStringRBT]) {
					soundIndex = kSoundRBT;			
				} else if ([type isEqualToString:kStringCrash]) {
					soundIndex = kSoundTrafficHazard;			
				} else if ([type isEqualToString:kStringDelay]) {
					soundIndex = kSoundTrafficDelay;
				} else {
					soundIndex = kSoundTrafficDelay;			
				}
				[(SoundEffect *)[soundEffects objectAtIndex:soundIndex] play];	
				break;
			}					
		}		
	}
}

- (void)didReceiveLocationUpdate:(CLLocationCoordinate2D)location speedkmh:(float)speedkmh course:(float)course {
	NSLog(@"didReceiveLocationUpdate %f %f %f %f", location.latitude, location.longitude, speedkmh, course);
	latestLocation = location;
	latestSpeedkmh = speedkmh;
	latestCourse = course;
	
	[[self mapView] moveToLatLong:location];
	[[[self mapView] markerManager] moveMarker:userMark AtLatLon:location];
	[userMark unhide];
	
	[self checkAlertsAtNewLocation:location];	
}

- (void)showUserOptionsDialog {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Hazard Type" 
															 delegate:self
													cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
													otherButtonTitles:@"Speed Camera"
								  , @"Traffic Delay"
								  , nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.delegate = self;
	[actionSheet showInView:self.view];
	[actionSheet release];		
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	//NSLog(@"clickedButtonAtIndex %d", buttonIndex);
	if (buttonIndex != actionSheet.cancelButtonIndex) {
		NSInteger index = buttonIndex - actionSheet.firstOtherButtonIndex;
		if (index == 0) {
			// Speed Camera
			[(SoundEffect *)[soundEffects objectAtIndex:kSoundSpeedCamera] play];
			if (latestLocation.longitude >= 0) {
				[post postIncident:@"speedcam_mobile" location:latestLocation];				
			}
		} else {
			// Traffic Delay
			[(SoundEffect *)[soundEffects objectAtIndex:kSoundTrafficDelay] play];
			if (latestLocation.longitude >= 0) {
				[post postIncident:@"delay" location:latestLocation];			
			}
		}
	}
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
	button.alpha = 0.6;
	
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
	[soundEffects release];
    [super dealloc];
}

@end
