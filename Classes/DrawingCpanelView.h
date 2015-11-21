//
//  DrawingCpanelView.h
//  MapDistance
//
//  Created by Christian Dunn on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapDistanceCanvas.h"
#import "MapDistancePathOverlayView.h"
#import "LabelWithAction.h"

@interface DrawingCpanelView : UIView {
    
    UIScrollView *mainScrollView;
    UISwitch *allowDrawSwitch;
    UISwitch *straightLineSwitch;
    UISwitch *useAreaSwitch;
    UILabel *allowDrawLabel;
    UILabel *straightLineLabel;
    UILabel *useAreaLabel;
    UIButton *addNewMeasurementButton;
    UILabel *addNewMeasurementLabel;
    NSInvocation *settingsButtonPressed;
    BOOL isVisibleInMainView;
    
    MapDistanceCanvas *canvas;
    MKPolyline *polyLine;
    MKPolygon *polygon;
    MKMapView *map_view;
    LabelWithAction *areaLabel;
    NSUserDefaults *defs;
    UIAlertView *copyToPasteboardAlert;
}

@property (assign) UISwitch *allowDrawSwitch;
@property (assign) UISwitch *straightLineSwitch;
@property (assign) UISwitch *useAreaSwitch;
@property (retain) NSInvocation *settingsButtonPressed;
@property (assign) BOOL isVisibleInMainView;

@property (assign) MapDistanceCanvas *canvas;
@property (assign) MKMapView *map_view;
@property (assign) UILabel *areaLabel;

- (void)allowDrawToggle;
- (void)useAreaToggle;
- (void)useAreaToggleNoOpen;
- (void)areaWasCalculated;
- (void)canvasWasRemoved;
- (void)addNewMeasurement;
- (void)topLabelActivated;

@end
