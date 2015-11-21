//
//  MapDistanceLatlonView.m
//  MapDistance
//
//  Created by Christian Dunn on 12/28/12.
//
//

#import "MapDistanceLatlonView.h"

@implementation MapDistanceLatlonView

- (void)setMapView:(MKMapView *)mapView {
    
    map = mapView;
    latlines = [NSMutableArray arrayWithCapacity:100];
    [latlines retain];
}

- (BOOL)overlayIsLatLon:(id<MKOverlay>)overlay {
    
    return [latlines containsObject:overlay];
}

- (MKOverlayView *)viewForOverlay:(MKPolyline *)overlay {
    
    return nil;
}

- (void)refreshMap {
    
    ;
}

- (void)removeLatLonLines {
    
    ;
}

@end
