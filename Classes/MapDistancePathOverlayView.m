//
//  MapDistancePathOverlayView.m
//  MapDistance
//
//  Created by Christian Dunn on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MapDistancePathOverlayView.h"

@implementation MapDistancePathOverlayView

-(CGPoint)pointFromLatLon:(PixelLocation *)latlon {
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latlon.latitude, latlon.longitude);
    MKMapPoint map_point = MKMapPointForCoordinate(coord);
    MKMapRect map_rect = MKMapRectMake(map_point.x, map_point.y, 5, 5);
    CGRect rect = [self rectForMapRect:map_rect];
    CGPoint point = CGPointMake(rect.origin.x, rect.origin.y);
    return point;
}

-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
//    
//    canvas = (MapDistanceCanvas *)(self.overlay);
//    NSMutableArray *drawing_path = [canvas drawing_path];
//    PixelLocation *px;
//    CGPoint pt;
//    double square_size;
//    
//    /* Actually draw the path elements (Squares) */
//    square_size = 5.0/zoomScale;
//    double half_square_size = square_size / 2.0;
//    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.0f green:1.0 blue:0.0f alpha:0.9f] CGColor]);
//    for (NSInteger i=0; i<[drawing_path count]; i+=1) {
//        px = [drawing_path objectAtIndex:i];
//        pt = [self pointFromLatLon:px];
//        CGContextFillRect(context, CGRectMake(pt.x - half_square_size, pt.y - half_square_size, square_size, square_size));
//    }
}

@end
