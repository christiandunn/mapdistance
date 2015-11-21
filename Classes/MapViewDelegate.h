//
//  MapViewDelegate.h
//  MapDistance
//
//  Created by Christian Dunn on 8/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapScaleView.h"
#import "MapScaleAnnotation.h"
#import "MapDistanceCanvas.h"
#import "MapDistancePathOverlayView.h"
#import "FoundPointAnnotation.h"
#import "MapDistanceLatlonView.h"
#import "MapDistancePersistentOverlayView.h"

@interface MapViewDelegate : NSObject <MKMapViewDelegate> {
    
    MapScaleView *mapScaleView;
    MapScaleView *overlayeredMapScaleView;
    MapScaleView *overlayeredMapScaleViewTwo;
    MapScaleAnnotation *theAnnotation;
    NSMutableArray *arrayOfViews;
    NSMutableArray *pinsOnMap;
    MapDistanceLatlonView *latlonmgr;
    MKMapView *defaultMapView;
    MapDistancePersistentOverlayView *mapOverlayView;
    NSTimer *workTimer;
    MapDistanceCanvas *mainCanvas;
}

@property (assign) MapScaleView *mapScaleView;
@property (assign) MapScaleView *overlayeredMapScaleView;
@property (assign) MapScaleView *overlayeredMapScaleViewTwo;
@property (assign) MapDistancePersistentOverlayView *mapOverlayView;
@property (assign) MKMapView *defaultMapView;
@property (assign) MapDistanceCanvas *mainCanvas;

- (void)initializeThis;
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated;
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay;
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view;
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation;

- (void)orientationChanged:(UIDeviceOrientation)orient;

- (void)saveMapState:(MKMapView *)_mapView;
- (void)loadMapState:(MKMapView *)_mapView;
- (MKPointAnnotation *)addPinToMap:(CLLocationCoordinate2D)location andS1:(NSString *)str1 andS2:(NSString *)str2;
- (void)removeAllPins;
- (void)regionChangedWork;

@end