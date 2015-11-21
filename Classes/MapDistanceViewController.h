//
//  MapDistanceViewController.h
//  MapDistance
//
//  Created by Christian Dunn on 12/19/10.
//  Copyright 2010 C. Dunn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapDistanceCanvas.h"
#import "MapDistanceConfigButtonView.h"
#import "SearchBarDelegate.h"
#import "MapScaleAnnotation.h"
#import "MapScaleView.h"
#import "MapViewDelegate.h"
#import "DrawingCpanelView.h"
#import "FoundPointAnnotation.h"
#import "MapDistanceAboutViewController.h"
#import "AppReviewQuestion.h"
#import "MapDistanceModeSelectorView.h"

#define DEFAULT_DONE_ITEM_TITLE @"Draw"

#define DRAWING (canvas != nil)

@interface MapDistanceViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, MapDistanceViewControllerProtocol> {
	
	IBOutlet MKMapView *map_view;
	IBOutlet UIButton *mapButton;
	IBOutlet UIButton *locationButton;
	IBOutlet UIButton *drawButton;
    IBOutlet UIButton *allowMoveButton;
	IBOutlet UIButton *undoButton;
	IBOutlet UINavigationBar *navigation_bar;
    IBOutlet UIBarButtonItem *doneItem;
    IBOutlet UIBarButtonItem *drawItem;
    IBOutlet UIButton *zoomOutButton;           //Debug mode option
    
    /* Search features */
    IBOutlet UISearchBar *searchBar;
    UIAlertView *searchDidReturnAlertView;
    MKCoordinateRegionWrapper *lastReturnedSearchLocation;
	
	NSUserDefaults *defaults;
    UIAlertView *alertViewIntro;
    UIAlertView *alertViewTrash;
    AppReviewQuestion *arq;
    
    float MAP_VIEW_HEIGHT_DEFAULT;
	
	NSString *currentLocale;
	NSString *currentLanguage;
	NSString *language;
	
	CLLocationManager *location_manager;
	
	double distance_per_latitude;	//meters
	double distance_per_longitude;	//meters
	double radius_at_latitude;		//meters
	
	MapDistanceCanvas *canvas;
	MapDistanceConfigButtonView *config_view;
    SearchBarDelegate *searchBarDelegate;
    MapViewDelegate *mapViewDelegate;
    MapScaleView *mapScaleView;
    MapDistanceModeSelectorView *modeSelectorView;
    
    DrawingCpanelView *drawingCpanel;
    BOOL drawCpanelIsVisible;
	BOOL drawCpanelIsEnabled;
    NSNotification *orChangedNote;
    
    UIColor *doneItemDefaultColor;
    UIColor *doneItemDrawColor;
    UIColor *doneItemDoneColor;
}

- (void)updateMapWithLocation:(CLLocation *)location andChangeZoom:(BOOL)change_zoom;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated;

- (IBAction)mapTypeButtonPressed;
- (IBAction)locationButtonPressed;
- (IBAction)drawButtonPressed;
- (IBAction)infoButtonPressed;
- (IBAction)undoButtonPressed;
- (IBAction)settingsButtonPressed:(id)sender;
- (IBAction)allowMoveButtonPressed:(id)sender;
- (IBAction)doneItemPressed:(id)sender;
- (IBAction)pinButtonPressed:(id)sender;
- (IBAction)addMeas:(id)sender;
- (void)addPin:(NSInteger)choice andCoord:(CLLocationCoordinate2D)_coord andS1:(NSString *)_str1 andS2:(NSString *)_str2;
- (void)orientationChanged:(NSNotification *)note;
- (void)orientationChangedTimer;

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
- (void)infoButtonViewCloseButtonPressed;
- (void)searchResultReturnedLocation:(MKCoordinateRegionWrapper *)location;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)removeCanvas;
- (void)performUndo;
- (void)refreshUnits;
- (void)setShowDrawCpanel:(BOOL)_show;

- (void)applicationWillResignActive;
- (void)applicationWillClose;

@end

