//
//  PixelLocation.m
//  MapDistance
//
//  Created by Christian Dunn on 12/19/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "PixelLocation.h"


@implementation PixelLocation

@synthesize x;
@synthesize y;

@synthesize latitude;
@synthesize longitude;

@synthesize costsUndo;
@synthesize MapViewPin;

+ (PixelLocation *)pixelLocationWithX:(NSInteger)_x andY:(NSInteger)_y {
	
	PixelLocation *px= [PixelLocation new];
	[px setX:_x];
	[px setY:_y];
    [px setCostsUndo:TRUE];
    [px setMapViewPin:nil];
	return px;
}

+ (PixelLocation *)pixelLocationWithLatitude:(double)_lat andLongitude:(double)_lon {
	
	PixelLocation *px= [PixelLocation new];
	[px setLatitude:_lat];
	[px setLongitude:_lon];
    [px setCostsUndo:TRUE];
    [px setMapViewPin:nil];
	return px;
}

- (CGPoint)getCGPoint {
	
	return CGPointMake(x, y);
}

@end
