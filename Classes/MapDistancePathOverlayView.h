//
//  MapDistancePathOverlayView.h
//  MapDistance
//
//  Created by Christian Dunn on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapDistanceCanvas.h"
#import "PixelLocation.h"

@interface MapDistancePathOverlayView : MKOverlayView {
    
    MapDistanceCanvas *canvas;
    NSMutableArray *allPoints;
}

-(CGPoint)pointFromLatLon:(PixelLocation *)latlon;
-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context;

@end
