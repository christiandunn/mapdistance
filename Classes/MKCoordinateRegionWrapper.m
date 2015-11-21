//
//  MKCoordinateRegionWrapper.m
//  MapDistance
//
//  Created by Christian Dunn on 6/30/14.
//
//

#import "MKCoordinateRegionWrapper.h"

@implementation MKCoordinateRegionWrapper

@synthesize region;
@synthesize string1;
@synthesize string2;

- (NSString *) toString {
    
    return [NSString stringWithFormat:@"Center Latitude: %f, Center Longitude: %f", region.center.latitude, region.center.longitude];
}

- (void) toLog {
    NSLog(@"%@", [self toString]);
}

@end
