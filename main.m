//
//  main.m
//  MapDistance
//
//  Created by Christian Dunn on 12/19/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>

double calculateDistance(double lat1, double lon1, double lat2, double lon2)    {
	double dLat;
	double dLon;
	double a;
	double c;
	double distance;
	
	//This formula calculates the great circle distance 
	//between two latitude/longitude coordinates
	dLat=((lat2-lat1)*PI_APPROX/180);
	dLon=((lon2-lon1)*PI_APPROX/180);
	a=pow(sin(dLat/2),2) + cos(lat1*PI_APPROX/180)*cos(lat2*PI_APPROX/180)*pow(sin(dLon/2),2);
	c=2*atan2(sqrt(a), sqrt(1-a));
	distance=RADIUS_OF_EARTH*c;
	return distance;
}

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"MapDistanceAppDelegate");
    [pool release];
    return retVal;
}
