//
//  PostHandler.m
//  iSpeedApp
//
//  Created by Graham Dawson on 17/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PostHandler.h"

const NSString *kBaseURL = @"http://www.littlebirdit.com/is/";
const NSString *kQueryName = @"report.php";

@implementation PostHandler

- (void)postIncident:(NSString *)type location:(CLLocationCoordinate2D)location {
	
	NSString *udid =  [[UIDevice currentDevice] uniqueIdentifier];	
	
	NSString *urlstring = [NSString stringWithFormat:@"%@%@?lat=%f&lon=%f&type=%@&udid=%@", kBaseURL, kQueryName, location.latitude, location.longitude, type, udid];
	NSURL *url = [NSURL URLWithString:urlstring];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
	// Open a connection for the request
 	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
 	if (connection) {
		if (receivedData != nil) {
			[receivedData release];
		}
		receivedData = [[NSMutableData data] retain];
		NSLog(@"Sent Post: %@", urlstring);		
	} else {
		NSLog(@"Unable to connect: %@", urlstring);		
	}

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data { 
	[receivedData appendData:data]; 		
} 

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { 
	NSLog(@"connection didFailWithError: %d, %@", connection, error.localizedDescription); 
} 

- (void)connectionDidFinishLoading:(NSURLConnection *)connection { 
	NSLog(@"connectionDidFinishLoading: %d bytes", [receivedData length]);
	NSLog(@"Contents: %@", receivedData);
} 

@end
