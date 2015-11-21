//
//  MapDistanceLatlonView.h
//  MapDistance
//
//  Created by Christian Dunn on 12/28/12.
//
//

#import <UIKit/UIKit.h>
#import "CMDGreatCircle.h"

#define MAX_POINTS 2

@interface MapDistanceLatlonView : NSObject {
    
    MKMapView *map;
    NSMutableArray *latlines;
}

- (void)setMapView:(MKMapView *)mapView;
- (BOOL)overlayIsLatLon:(id<MKOverlay>)overlay;
- (MKOverlayView *)viewForOverlay:(MKPolyline *)overlay;
- (void)refreshMap;
- (void)removeLatLonLines;

@end
