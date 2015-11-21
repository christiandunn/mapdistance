//
//  PixelLocation.h
//  MapDistance
//
//  Created by Christian Dunn on 12/19/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PixelLocation : NSObject {
	
	NSInteger x;
	NSInteger y;
	
	double latitude;
	double longitude;
    
    BOOL costsUndo;
    MKPointAnnotation *MapViewPin;
}

@property NSInteger x;
@property NSInteger y;

@property double latitude;
@property double longitude;

@property BOOL costsUndo;
@property (assign) MKPointAnnotation *MapViewPin;

+ (PixelLocation *)pixelLocationWithX:(NSInteger)_x andY:(NSInteger)_y;
+ (PixelLocation *)pixelLocationWithLatitude:(double)_lat andLongitude:(double)_lon;

- (CGPoint)getCGPoint;

@end
