//
//  MapDistanceCanvas.h
//  MapDistance
//
//  Created by Christian Dunn on 12/19/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixelLocation.h"
#import "LabelWithAction.h"
#import "CDVectorMath.h"
#import "CMDGreatCircle.h"

#define MAP_MARGIN 20

#define DONE_BUTTON_TEXT @"DoneButtonItemText"

double calculateDistance(double lat1, double lon1, double lat2, double lon2);

@interface MapDistanceCanvas : UIView <MKOverlay, UIAlertViewDelegate> {
	
    /* State variables */
    NSInteger y_offset;
    NSInteger map_moving;
    BOOL isAnimating;
    BOOL frozen;
    BOOL demandsAreaCalculation;
    /* Mode: 0 = Normal (path distance), 1 = Area */
    NSInteger mode;
    /* Area find mode: 0 = Simplest (square pixels), 1 = Medium (convert to distance), 2 = High, 3 = Long (old style, using the flood fill method */
    NSInteger areaFindMode;
    /* Canvas status: 0 = untouched, 1 = looking for a spot, 2 = full path */
    NSInteger canvas_status;
    NSInteger measurementsCount;
    NSString *topBarString;
    /* Tutorializing */
    UILabel *drawEnabledLabel;
    UIImageView *drawEnabledIcon;
    UIView *moveMapTutorialView;
    UILabel *mapMoveTutorialLabel;
    UIColor *colorTranspar;
    UIColor *colorTransparRed;
    UIView *drawTutorialBackView;
    
    /* Map region has changed (More state variables) */
	UIButton *button_continue;
    /* Cursor pixel represents where the touch actually is */
    CGPoint cursor_pixel;
    CGPoint polygon_intersect;
    
    /* Calculated variables */
    double distance;
    double prev_meas_distance;
    double area;
    double prev_meas_area;
    
    /* External objects */
    MKMapView *mapView;
    id drawing_cpanel_view;
    NSInvocation *areaCalculatedInvocation;

    /* Miscellaneous */
	NSMutableArray *drawing_path; //PixelLocations with latitudes and longitudes
	NSMutableArray *mile_markers;
	NSUserDefaults *user_defaults;
	NSString *language;
	CGPoint first_pixel;
	UIDevice *current_device;
	UITouch *last_input;
    NSThread *findAreaThread;
    BOOL useAutomaticScroll;
    BOOL isBeingInteractedWith;
    UIAlertView *copyToPasteboardAlert;
    UIAlertView *drawPathAlertView;
    NSTimer *timerForDrawEnabledAnimator;
    NSNumberFormatter *nf;
    
    /* MKOverlay variables */
    CLLocationCoordinate2D coordinate;
    MKMapRect boundingMapRect;
    MKPolygon *innerPolygon;
    double minLat;
    double maxLat;
    double minLon;
    double maxLon;
	
	/* These variables are calculated */
    NSRange pointsOfPolygon;
    NSMutableArray *pointsToFill;
    PixelLocation *pointOfIntersection;
    NSString *lastDrawnTopBarString;
    LabelWithAction *topBarLabel;
}

@property (assign) MKMapView *mapView;
@property (retain) NSString *language;
@property (assign, readonly) NSMutableArray *drawing_path;
@property (assign) NSInteger mode;
@property BOOL isAnimating;
@property BOOL useAutomaticScroll;
@property (readonly) double distance;
@property (readonly) double area;
@property (readonly) NSRange pointsOfPolygon;
@property (readonly) PixelLocation *pointOfIntersection;
@property (assign) id drawing_cpanel_view;
@property (assign) NSString *lastDrawnTopBarString;
@property (readonly) MKPolygon *innerPolygon;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) MKMapRect boundingMapRect;
- (BOOL)intersectsMapRect:(MKMapRect)mapRect;

void centerTextInContextAtOrigin(
								 CGContextRef cgContext,
								 CGFloat x, CGFloat y,
								 const  char *fontName,
								 float textSize,
								 const char *text);

- (NSInteger)undo:(NSInteger)undo_count;
- (void)configureCanvasForDrawing;
- (void)mapRegionChanged;
- (void)mapRegionContinue;
- (void)calculateOverlay;
- (void)drawTopLabel:(NSString *)str;
- (void)drawRect:(CGRect)rect;
- (double)calculateDistance;
- (void)calculateAreaThread;
- (void)areaCalculated:(NSNumber *)_area;
- (void)setAreaCalculatedUpdate:(NSInvocation *)inv;
- (BOOL)lineSegmentsIntersect:(PixelLocation *)ls1pt1 andPt:(PixelLocation *)ls1pt2 andPt:(PixelLocation *)ls2pt1 andPt:(PixelLocation *)ls2pt2 andIXPtr:(double *)ix andIYPtr:(double *)iy;
- (void)calculateAreaPrivate;
- (void)checkThreadCancel;
- (void)topLabelActivated;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)aboutToBeRemoved;
- (void)drawEnabledIconAnimator;
- (void)disableTutorialAnimations;
- (BOOL)pathCheckIntersectionAtIndex:(NSInteger)i;
- (PixelLocation *)addPointToPathAtViewPoint:(CGPoint)point;
- (PixelLocation *)addCoordinateToPath:(CLLocationCoordinate2D)_coord withGC:(BOOL)gc;
- (double)distanceForRestOfPath:(CLLocationCoordinate2D)coord;
- (double)distanceToLastPoint:(CLLocationCoordinate2D)coord;
- (NSString *)stringForDistanceOrArea:(double)distance_delta;
- (NSString *)stringForDistanceOrAreaPrivate:(double)d andArea:(double)a andMode:(NSInteger)m andDelta:(double)distance_delta;
- (void)addNewMeasurement;

@end
