//
//  MapViewDelegate.m
//  MapDistance
//
//  Created by Christian Dunn on 8/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewDelegate.h"


@implementation MapViewDelegate

@synthesize mapScaleView;
@synthesize overlayeredMapScaleView;
@synthesize overlayeredMapScaleViewTwo;
@synthesize defaultMapView;
@synthesize mapOverlayView;
@synthesize mainCanvas;

- (void)initializeThis {
    
    arrayOfViews = [NSMutableArray arrayWithCapacity:5];
    [arrayOfViews retain];
    pinsOnMap = [NSMutableArray arrayWithCapacity:5];
    [pinsOnMap retain];
    //mapScaleView = [[MapScaleView alloc] init];
    //[mapScaleView initializeThis];
    latlonmgr = [MapDistanceLatlonView new];
    [latlonmgr setMapView:defaultMapView];
    
    workTimer = nil;
    
    mapOverlayView = [[MapDistancePersistentOverlayView alloc] initWithFrame:CGRectMake(0, 0, defaultMapView.frame.size.width, defaultMapView.frame.size.height)];
    [mapOverlayView setMapView:defaultMapView];
    [defaultMapView addSubview:mapOverlayView];
    
    mainCanvas = nil;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [mapOverlayView setEffectivelyHidden:TRUE];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    [latlonmgr removeLatLonLines];
    [self regionChangedWork];
    [mapOverlayView setEffectivelyHidden:FALSE];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    MapScaleView *mapScaleAnnotation;
    
    if ([annotation isKindOfClass:[FoundPointAnnotation class]]) {
        
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        return pin;
    }
    
    if ([annotation isKindOfClass:[MapScaleAnnotation class]]) {
        
        theAnnotation = annotation;
        
		//Try to dequeue an existing custom annotation view first
		mapScaleAnnotation = (MapScaleView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"id1"];
		
		if(!mapScaleAnnotation)
		{
			//If a trip view annotation was not available, make one
			mapScaleAnnotation = [[[MapScaleView alloc] initWithAnnotation:annotation reuseIdentifier:@"id1"] autorelease];
			mapScaleAnnotation.frame = CGRectMake(0.0f, 0.0f, mapView.frame.size.width, mapView.frame.size.height);
			mapScaleAnnotation.opaque = 0;
            [arrayOfViews addObject:mapScaleAnnotation];
            if([arrayOfViews count] > 1) {
                
                while([arrayOfViews count]>1) {
                    
                    MapScaleView *obj = [arrayOfViews objectAtIndex:0];
                    [obj retain];
                    [arrayOfViews removeObjectAtIndex:0];
                    [obj removeFromSuperview];
                }
            }
		} else {
            
            [mapScaleAnnotation setNeedsDisplay];
        }
		
		mapScaleAnnotation.clipsToBounds = 0;
        [mapScaleAnnotation setTheMapView:mapView];
		
		return mapScaleAnnotation;
	} else {
        
        return nil;
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    if ([overlay class] == [MapDistanceCanvas class]) {
        
        MapDistancePathOverlayView *overlayView = [[MapDistancePathOverlayView alloc] initWithOverlay:overlay];
        [overlayView setHidden:FALSE];
        [overlayView setUserInteractionEnabled:FALSE];
        return overlayView;
    }
    
    BOOL isLatLonLine = [latlonmgr overlayIsLatLon:overlay];
    if (isLatLonLine) {
        MKOverlayView *ov = [latlonmgr viewForOverlay:(MKPolyline *)overlay];
        return ov;
    }
    
    if ([overlay class] == [MKPolyline class] && !isLatLonLine) {
        
        MKPolyline *pline = (MKPolyline *)overlay;
        MKPolylineView *polyLineView = [[MKPolylineView alloc] initWithPolyline:pline];
        [polyLineView setStrokeColor:[UIColor redColor]];
        [polyLineView setLineWidth:2.5f];
        return polyLineView;
    }
    
    if ([overlay class] == [MKPolygon class]) {
        
        MKPolygon *polygon = (MKPolygon *)overlay;
        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:polygon];
        [polygonView setFillColor:[UIColor greenColor]];
        [polygonView setAlpha:0.35f];
        return polygonView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if (mainCanvas != nil) {
        NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
        [user_defaults synchronize];
        NSInteger metric= [user_defaults integerForKey:@"metric"];
        
        if (metric == 2) {
            // Golf Mode
            CLLocation *loc = [[defaultMapView userLocation] location];
            double dist = [mainCanvas distanceToLastPoint:[loc coordinate]];
            NSString *str = [mainCanvas stringForDistanceOrAreaPrivate:dist andArea:0.0 andMode:0 andDelta:0];
            [[defaultMapView userLocation] setTitle:str];
            [[defaultMapView userLocation] setSubtitle:NSLocalizedString(@"RemainingToHole", @"")];
            // End Golf Mode
        } else {
            // Find point nearest to current location on path
            CLLocation *loc = [[defaultMapView userLocation] location];
            double dist = [mainCanvas distanceForRestOfPath:[loc coordinate]];
            NSString *str = [mainCanvas stringForDistanceOrAreaPrivate:dist andArea:0.0 andMode:0 andDelta:0];
            [[defaultMapView userLocation] setTitle:str];
            [[defaultMapView userLocation] setSubtitle:NSLocalizedString(@"RemainingOnPath", @"")];
            // End Find Point Nearest Mode
        }
        
    } else {
        [[defaultMapView userLocation] setTitle:NSLocalizedString(@"CurrentLocation", @"")];
        [[defaultMapView userLocation] setSubtitle:@""];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    ;
}

- (void)orientationChanged:(UIDeviceOrientation)orient {
    
    [mapOverlayView setFrame:CGRectMake(0, 0, defaultMapView.frame.size.width, defaultMapView.frame.size.height)];
    [mapOverlayView setNeedsDisplay];
}

- (void)saveMapState:(MKMapView *)_mapView {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:_mapView.region.center.latitude forKey:@"MapDistanceCenterLatitude"];
    [defaults setDouble:_mapView.region.center.longitude forKey:@"MapDistanceCenterLongitude"];
    [defaults setDouble:_mapView.region.span.latitudeDelta forKey:@"MapDistanceLatitudeDelta"];
    [defaults setDouble:_mapView.region.span.longitudeDelta forKey:@"MapDistanceLongitudeDelta"];
    [defaults setBool:TRUE forKey:@"MapDistancePreviousData"];
    [defaults synchronize];
}

- (void)loadMapState:(MKMapView *)_mapView {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults retain];
    BOOL prevdata = [defaults boolForKey:@"MapDistancePreviousData"];
    if (prevdata) {
        double c_lat = [defaults doubleForKey:@"MapDistanceCenterLatitude"];
        double c_lon = [defaults doubleForKey:@"MapDistanceCenterLongitude"];
        double delta_lat = [defaults doubleForKey:@"MapDistanceLatitudeDelta"];
        double delta_lon = [defaults doubleForKey:@"MapDistanceLongitudeDelta"];
        MKCoordinateRegion region = [_mapView regionThatFits:MKCoordinateRegionMake(CLLocationCoordinate2DMake(c_lat, c_lon), MKCoordinateSpanMake(delta_lat, delta_lon))];
        [_mapView setRegion:region];
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [_mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(42.7, -97.8), MKCoordinateSpanMake(64.257, 65.344))];
        }
    }
}

- (MKPointAnnotation *)addPinToMap:(CLLocationCoordinate2D)location andS1:(NSString *)str1 andS2:(NSString *)str2 {
    
    MKPointAnnotation *a = [[MKPointAnnotation alloc] init];
    [a setCoordinate:location];
    if (str1 != nil) {
        [a setTitle:str1];
    } else {
        [a setTitle:[NSString stringWithFormat:@"%f, %f", location.latitude, location.longitude]];
    }
    if (str2 != nil) {
        [a setSubtitle:str2];
    } else {
        [a setSubtitle:[NSString stringWithFormat:@"Pin ID: %lu", (unsigned long)[pinsOnMap count]]];
    }
    [defaultMapView addAnnotation:a];
    [pinsOnMap addObject:a];
    return a;
}

- (void)removeAllPins {
    
    for (MKPointAnnotation *pin in pinsOnMap) {
        [defaultMapView removeAnnotation:pin];
    }
    [pinsOnMap removeAllObjects];
}

- (void)regionChangedWork {
    workTimer = nil;
    
    [self saveMapState:defaultMapView];
    [overlayeredMapScaleView setNeedsDisplay];
    [overlayeredMapScaleViewTwo setNeedsDisplay];
    
    [latlonmgr refreshMap];
    [mapOverlayView setFrame:CGRectMake(0, 0, defaultMapView.frame.size.width, defaultMapView.frame.size.height)];
    [mapOverlayView setNeedsDisplay];
}

@end
