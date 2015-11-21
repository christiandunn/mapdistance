//
//  CDVectorMath.h
//  MapDistance
//
//  Created by Christian Dunn on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PixelLocation.h"
#import "CDLineSegment.h"
#import "CDLineSegmentIntersectionResult.h"

double calculateDistance(double lat1, double lon1, double lat2, double lon2);
double sigFigs(double v, NSInteger n);

@interface CDVectorMath : NSObject

+ (CDLineSegmentIntersectionResult *)intersectionOfTwoLineSegments:(CDLineSegment *)ls1 andOther:(CDLineSegment *)ls2;
+ (CLLocationCoordinate2D)intersectionOfTwoLatLonLineSegments:(CDLineSegment *)ls1 andOther:(CDLineSegment *)ls2;
+ (BOOL)latLonInBounds:(CLLocationCoordinate2D)latlong1 andY:(CLLocationCoordinate2D)latlong2 checking:(CLLocationCoordinate2D)latlong3;
+ (double)integrateGreensTheoremOverLineSegment:(CDLineSegment *)lineSegment andMapView:(MKMapView *)mapView andOverlayView:(UIView *)overlayView;
+ (double)distanceBetweenPoint:(PixelLocation *)point1 andPoint:(PixelLocation *)point2;

@end