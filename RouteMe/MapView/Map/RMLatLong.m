/*
 *  RMLatLong.c
 *  MapView
 *
 *  Created by Joseph Gentle on 17/01/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "RMLatLong.h"

float RMLatLongOrthogonalDistance(RMLatLong first, RMLatLong second)
{
	return sqrtf((first.latitude - second.latitude) * (first.latitude - second.latitude)
				 + (first.longitude - second.longitude) * (first.longitude - second.longitude));
}