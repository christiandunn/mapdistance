//
//  MapDistancePersistentOverlayView.h
//  MapDistance
//
//  Created by Christian Dunn on 12/28/12.
//
//

#import <UIKit/UIKit.h>
#import "CMDGreatCircle.h"

double pow10roundUp(double number, double calibration);

@interface MapDistancePersistentOverlayView : UIView {
    
    MKMapView *map;
    CGPoint center;
    BOOL effectivelyHidden;
    
    UILabel *latlonLabel;
}

@property CGPoint center;

- (void)setMapView:(MKMapView *)mapView;
- (void)setEffectivelyHidden:(BOOL)tf;

@end
