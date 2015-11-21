//
//  CDVectorMath.m
//  MapDistance
//
//  Created by Christian Dunn on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  Mathematical source: http://paulbourke.net/geometry/lineline2d/
//  Essentially solve the equations for intersection of the following:
//  P_a = P1 + u_a(P2 - P1)
//  P_b = P3 + u_b(P4 - P3)
//  Setting P_a equal to P_b
//

#import "CDVectorMath.h"

@implementation CDVectorMath

+ (CDLineSegmentIntersectionResult *)intersectionOfTwoLineSegments:(CDLineSegment *)ls1 andOther:(CDLineSegment *)ls2 {
    
    double x1, x2, x3, x4;
    double y1, y2, y3, y4;
    
    x1 = ls1.point1.x;
    x2 = ls1.point2.x;
    x3 = ls2.point1.x;
    x4 = ls2.point2.x;
    
    y1 = ls1.point1.y;
    y2 = ls1.point2.y;
    y3 = ls2.point1.y;
    y4 = ls2.point2.y;
    
    double numerator = (x4 - x3)*(y1 - y3) - (y4 - y3)*(x1 - x3);
    double numeratorb = (x2 - x1)*(y1 - y3) - (y2 - y1)*(x1 - x3);
    double denominator = (y4 - y3)*(x2 - x1) - (x4 - x3)*(y2 - y1);
    double u_a = -1;
    double u_b = -1;
    if (denominator != 0) {
        u_a = numerator / denominator;
        u_b = numeratorb / denominator;
    }
    
    CGPoint intersection = CGPointMake(x1 + u_a*(x2 - x1), y1 + u_a*(y2 - y1));
    
    CDLineSegmentIntersectionResult *res = [[CDLineSegmentIntersectionResult alloc] init];
    
    res.intersects = (u_a >= 0 && u_a <= 1 && u_b >= 0 && u_b <= 1);
    res.intersection = intersection;
    
    return res;
}

+ (CLLocationCoordinate2D)intersectionOfTwoLatLonLineSegments:(CDLineSegment *)ls1 andOther:(CDLineSegment *)ls2 {
    //https://rbrundritt.wordpress.com/2008/10/20/approximate-points-of-intersection-of-two-line-segments/
    
    CLLocationCoordinate2D latlong1 = CLLocationCoordinate2DMake(ls1.point1.x, ls1.point1.y);
    CLLocationCoordinate2D latlong2 = CLLocationCoordinate2DMake(ls1.point2.x, ls1.point2.y);
    CLLocationCoordinate2D latlong3 = CLLocationCoordinate2DMake(ls2.point1.x, ls2.point1.y);
    CLLocationCoordinate2D latlong4 = CLLocationCoordinate2DMake(ls2.point2.x, ls2.point2.y);
    
    //Line segment 1 (p1, p2)
    double A1 = latlong2.latitude - latlong1.latitude;
    double B1 = latlong1.longitude - latlong2.longitude;
    double C1 = A1*latlong1.longitude + B1*latlong1.latitude;
    
    //Line segment 2 (p3,  p4)
    double A2 = latlong4.latitude - latlong3.latitude;
    double B2 = latlong3.longitude - latlong4.longitude;
    double C2 = A2*latlong3.longitude + B2*latlong3.latitude;
    
    double determinate = A1*B2 - A2*B1;
    
    if(determinate != 0)
    {
        double x = (B2*C1 - B1*C2)/determinate;
        double y = (A1*C2 - A2*C1)/determinate;
        CLLocationCoordinate2D intersect = CLLocationCoordinate2DMake(y, x);
        if ([self latLonInBounds:latlong1 andY:latlong2 checking:intersect] && [self latLonInBounds:latlong3 andY:latlong4 checking:intersect]) {
            return intersect;
        }
        return CLLocationCoordinate2DMake(0.0, 0.0);
    } else {
        return CLLocationCoordinate2DMake(0.0, 0.0);
    }
}

+ (BOOL)latLonInBounds:(CLLocationCoordinate2D)latlong1 andY:(CLLocationCoordinate2D)latlong2 checking:(CLLocationCoordinate2D)latlong3 {
    
    BOOL betweenLats;
    BOOL betweenLons;
    
    if(latlong1.latitude < latlong2.latitude)
        betweenLats = (latlong1.latitude <= latlong3.latitude &&
                       latlong2.latitude >= latlong3.latitude);
    else
        betweenLats = (latlong1.latitude >= latlong3.latitude &&
                       latlong2.latitude <= latlong3.latitude);
    
    if(latlong1.longitude < latlong2.longitude)
        betweenLons = (latlong1.longitude <= latlong3.longitude &&
                       latlong2.longitude >= latlong3.longitude);
    else
        betweenLons = (latlong1.longitude >= latlong3.longitude &&
                       latlong2.longitude <= latlong3.longitude);
    
    return (betweenLats && betweenLons);
}

+ (double)integrateGreensTheoremOverLineSegment:(CDLineSegment *)lineSegment andMapView:(MKMapView *)mapView andOverlayView:(UIView *)overlayView {
    
    //integral_over_perimeter(-y dx + x dy)
    
    CGPoint point1 = lineSegment.point1;
    CGPoint point2 = lineSegment.point2;
    
    double deltaX = point2.x - point1.x;
    double deltaY = point2.y - point1.y;
    
    return -point1.y*deltaX + point1.x*deltaY;
}

+ (double)distanceBetweenPoint:(PixelLocation *)point1 andPoint:(PixelLocation *)point2 {
    
    double deltaX = point2.x - point1.x;
    double deltaY = point2.y - point1.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY);
}

double sigFigs(double v, NSInteger n) {
    NSInteger digitsOriginal = (NSInteger)floor(log10(v)) + 1;
    double tenPower = pow(10.0, (digitsOriginal - 4.0));
    return round(v / tenPower) * tenPower;
}

@end
