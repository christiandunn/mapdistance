//
//  MapScaleAnnotation.m
//  MapDistance
//
//  Created by Christian Dunn on 8/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapScaleAnnotation.h"


@implementation MapScaleAnnotation

@synthesize coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
            
    coordinate = newCoordinate;
}

@end
