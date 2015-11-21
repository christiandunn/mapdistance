//
//  MapScaleAnnotation.h
//  MapDistance
//
//  Created by Christian Dunn on 8/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MapScaleAnnotation : NSObject <MKAnnotation> {
   
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
