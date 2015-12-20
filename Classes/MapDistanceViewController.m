//
//  MapDistanceViewController.m
//  MapDistance
//
//  Created by Christian Dunn on 12/19/10.
//  Copyright 2010 C. Dunn. All rights reserved.
//

#import "MapDistanceViewController.h"

@implementation MapDistanceViewController

 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
     ;
 }
 return self;
 }

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Gather necessary permissions for location updates
    location_manager= [[CLLocationManager alloc] init];
    location_manager.delegate= self;
    if (language==nil) {
        ;
        //[location_manager setPurpose:@"Location data is not necessary, but is generally recommended for the best user experience when using this application"];
    }
    if (IS_OS_8_OR_LATER) {
        [location_manager requestWhenInUseAuthorization];
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self locationManager:location_manager didChangeAuthorizationStatus:kCLAuthorizationStatusAuthorized];
    }
	
    //Define user defaults object here
	defaults= [NSUserDefaults standardUserDefaults];
	[defaults setInteger:1 forKey:@"program_loaded_previously"];
	[defaults synchronize];
	
    //Determine the app's language
	NSArray *languages= [defaults objectForKey:@"AppleLanguages"];
	currentLanguage= [languages objectAtIndex:0];
	currentLocale= [[NSLocale currentLocale] localeIdentifier];
	if ([currentLanguage compare:@"fr"]==NSOrderedSame) {
		language= @"fr_FR";
		[language retain];
	}
	else {
		language= nil;
	}
	
    //Set the titles of the various buttons according to language
	[mapButton setTitle:(NSString *)NSLocalizedString(@"Map Type", @"Map Type") forState:UIControlStateNormal];
	[locationButton setTitle:(NSString *)NSLocalizedString(@"Location", @"Location") forState:UIControlStateNormal];
	[drawButton setTitle:(NSString *)NSLocalizedString(@"Draw", @"Draw") forState:UIControlStateNormal];
	[[navigation_bar topItem] setTitle:(NSString *)NSLocalizedString(@"MapDistanceTitle", @"Map Distance")];
	[undoButton setTitle:(NSString *)NSLocalizedString(@"Undo", @"Undo") forState:UIControlStateNormal];
    [[undoButton titleLabel] setFont:[UIFont fontWithName:@"Helvetica" size:28.0f]];
	
    //Determine where the map appears when the app first starts
	CLLocation *last_application_location;
	double latitude= [defaults doubleForKey:@"latitude"];
	double longitude= [defaults doubleForKey:@"longitude"];
	double latitude_delta= [defaults doubleForKey:@"latitude_delta"];
	double longitude_delta= [defaults doubleForKey:@"longitude_delta"];
	last_application_location= [CLLocation alloc];
	[last_application_location initWithLatitude:latitude longitude:longitude];
	if ([defaults integerForKey:@"program_loaded_previously"]==1 && last_application_location!=nil) {
		if ((latitude>90 || latitude<-90) || (longitude>180 || longitude<-180)) {
			;
		}
		else {
			if (!(latitude==0 && longitude==0)) {
				[map_view setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude, longitude), MKCoordinateSpanMake(latitude_delta, longitude_delta))];
			}
		}
	} else {
        /* Default map view location */
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
            /* Default map view location with no location status known */
        } else {
            MKUserLocation *userLocation = [map_view userLocation];
            CLLocation *userLocationLocation = [userLocation location];
            [map_view setRegion:MKCoordinateRegionMake(userLocationLocation.coordinate, MKCoordinateSpanMake(latitude_delta, longitude_delta))];
        }
    }
    
    //Determine delegation for the search bar
    searchBarDelegate = [SearchBarDelegate new];
    [searchBar setDelegate:searchBarDelegate];
    [searchBar setShowsCancelButton:YES];
    [searchBarDelegate setVc:self];
    [searchBar setPlaceholder:NSLocalizedString(@"SearchBarPlaceholderTextIPHONE", @"")];
    [searchBarDelegate setMap_view:map_view];
    
    //Determine delegation for the map view
    mapViewDelegate = [MapViewDelegate new];
    [mapViewDelegate setDefaultMapView:map_view];
    [mapViewDelegate initializeThis];
    [map_view setDelegate:mapViewDelegate];
    
    //Initialize and add the map scale bar
    mapScaleView = [[MapScaleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    [mapScaleView initializeThis];
    [mapScaleView setTheMapView:map_view];
    [mapViewDelegate setOverlayeredMapScaleView:mapScaleView];
    [map_view addSubview:mapScaleView];
    [mapViewDelegate loadMapState:map_view];
    drawCpanelIsVisible = FALSE;
    drawCpanelIsEnabled = FALSE;
    
    if (drawingCpanel == nil) {
        drawingCpanel = [[DrawingCpanelView alloc] initWithFrame:CGRectMake(0, map_view.frame.origin.y, map_view.frame.size.width, HEIGHT_OF_DRAW_CPANEL)];
        [self.view addSubview:drawingCpanel];
        [self.view sendSubviewToBack:drawingCpanel];
        [drawingCpanel setCanvas:canvas];
        [drawingCpanel setMap_view:map_view];
        
        /* NSInvocation for closing up the control panel view from within */
        SEL theSelector;
        NSMethodSignature *aSignature;
        NSInvocation *anInvocation;
        theSelector = @selector(settingsButtonPressed:);
        aSignature = [MapDistanceViewController instanceMethodSignatureForSelector:theSelector];
        anInvocation = [NSInvocation invocationWithMethodSignature:aSignature];
        [anInvocation setSelector:theSelector];
        [anInvocation setTarget:self];
        [canvas setDrawing_cpanel_view:drawingCpanel];
        [drawingCpanel setSettingsButtonPressed:anInvocation];
    }
    
    MAP_VIEW_HEIGHT_DEFAULT = map_view.frame.size.height;
    
    [allowMoveButton setEnabled:FALSE];
    [drawButton setTitle:NSLocalizedString(@"DrawButton", @"") forState:UIControlStateNormal];
    [drawButton setTitle:NSLocalizedString(@"DrawButtonSelected", @"") forState:UIControlStateSelected];
    [locationButton setTitle:NSLocalizedString(@"LocationButton", @"") forState:UIControlStateNormal];
    
    [doneItem setTitle:NSLocalizedString(DEFAULT_DONE_ITEM_TITLE, @"")];
    doneItemDefaultColor = [doneItem tintColor];
    doneItemDrawColor = [UIColor blueColor];
    doneItemDoneColor = [UIColor redColor];
    [doneItemDefaultColor retain];
    [doneItemDoneColor retain];
    [doneItemDrawColor retain];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    if (language==nil) {
        //Check to see if the program has been run before:
        if ([defaults integerForKey:@"program_has_been_opened_before"]!=1) {
            alertViewIntro = [UIAlertView alloc];
            alertViewIntro = [alertViewIntro initWithTitle:@"Distance/Area" message:@"Thank you for using this app!\n\nDisclaimer: This app provides quick and easy estimation of distances and areas. Do not depend solely on the results provided." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            //[alertViewIntro show];
            
            LabelWithAction *startHereLabel = [[LabelWithAction alloc] initWithFrame:CGRectMake(0, map_view.frame.size.height - 35, 100, 35)];
            [startHereLabel setText:NSLocalizedString(@"StartHere", @"")];
            [startHereLabel setTextAlignment:NSTextAlignmentCenter];
            [startHereLabel setAdjustsFontSizeToFitWidth:TRUE];
            [startHereLabel setBackgroundColor:[UIColor yellowColor]];
            [startHereLabel setTextColor:[UIColor redColor]];
            [startHereLabel setDeleteTimerWithSeconds:25.0];
            [map_view addSubview:startHereLabel];
            
            [defaults setInteger:1 forKey:@"program_has_been_opened_before"];
        }
    }
    else {
        if ([language isEqualToString:@"fr_FR"]) {
            //Check to see if the program has been run before:
            if ([defaults integerForKey:@"program_has_been_opened_before"]!=1) {
                UIAlertView *alertView= [UIAlertView alloc];
                alertView= [alertView initWithTitle:@"Carte Outils" message:@"Appuyez sur la touche 'dessiner' si vous voulez dessiner un chemin sur la carte.\n\nAttention: Ce logiciel ne fournit pas d'informations précises." delegate:nil cancelButtonTitle:@"Fermer" otherButtonTitles:nil];
                //[alertView show];
                [alertView release];
                
                LabelWithAction *startHereLabel = [[LabelWithAction alloc] initWithFrame:CGRectMake(0, map_view.frame.size.height - 35, 100, 35)];
                [startHereLabel setText:NSLocalizedString(@"StartHere", @"")];
                [startHereLabel setTextAlignment:NSTextAlignmentCenter];
                [startHereLabel setAdjustsFontSizeToFitWidth:TRUE];
                [startHereLabel setBackgroundColor:[UIColor yellowColor]];
                [startHereLabel setTextColor:[UIColor redColor]];
                [startHereLabel setDeleteTimerWithSeconds:25.0];
                [map_view addSubview:startHereLabel];
                
                [defaults setInteger:1 forKey:@"program_has_been_opened_before"];
            }
        }
    }
    arq = [[AppReviewQuestion alloc] initWithConfig:defaults];
    [arq main];
    
    //VIEW DID LOAD - END
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    [mapScaleView setNeedsDisplay];
}

- (void)updateMapWithLocation:(CLLocation *)location andChangeZoom:(BOOL)change_zoom {
		
	CLLocation *recent_location= location;
	CLLocationCoordinate2D map_center_coordinate= [recent_location coordinate];
	if (change_zoom) {
		MKCoordinateSpan map_span= MKCoordinateSpanMake(1.000, 1.000);
		MKCoordinateRegion map_coordinate_region= MKCoordinateRegionMake(map_center_coordinate, map_span);
		[map_view setRegion:map_coordinate_region animated:TRUE];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	
    MKCoordinateRegion region = [map_view region];
	CLLocationCoordinate2D location = region.center;
	[defaults setDouble:location.latitude forKey:@"latitude"];
	[defaults setDouble:location.longitude forKey:@"longitude"];
	[defaults setDouble:region.span.latitudeDelta forKey:@"latitude_delta"];
	[defaults setDouble:region.span.longitudeDelta forKey:@"longitude_delta"];
	[defaults synchronize];
}

- (IBAction)mapTypeButtonPressed {
	
	if (map_view.mapType == MKMapTypeStandard) {
		[map_view setMapType:MKMapTypeHybrid];
		return;
	}
	
	if (map_view.mapType == MKMapTypeHybrid) {
		[map_view setMapType:MKMapTypeStandard];
		return;
	}
}

- (IBAction)drawButtonPressed {
    if (config_view != nil) {
        [self infoButtonViewCloseButtonPressed];
    }
    
	if (canvas==nil) {
        // This block is for BEGINNING a drawing session
        
        if (drawCpanelIsEnabled) {
            [self setShowDrawCpanel:TRUE];
        }
        
        void (^_animations)(void) = ^(void) {
            
            //[searchBar setAlpha:0.0f];
            //[searchBar setUserInteractionEnabled:FALSE];
            //[map_view setFrame:CGRectMake(map_view.frame.origin.x, searchBar.frame.origin.y, map_view.frame.size.width, map_view.frame.size.height + searchBar.frame.size.height)];
            [undoButton setHidden:FALSE];
            [undoButton setAlpha:1.0f];
            
            [doneItem setTitle:NSLocalizedString(@"DoneButtonItemText",@"")];
            [doneItem setTintColor:doneItemDoneColor];
            
            drawItem.image = [UIImage imageNamed:@"218-trash2.png"];
            drawItem.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        };
        [UIView animateWithDuration:0.25f animations:_animations];
        
		[allowMoveButton setEnabled:TRUE];
        [allowMoveButton setSelected:FALSE];
		canvas = [MapDistanceCanvas alloc];
		canvas = [canvas initWithFrame:map_view.frame];
        [mapViewDelegate setMainCanvas:canvas];
		[canvas setLanguage:language];
		[canvas setMapView:map_view];
        NSInteger mode = 0;
        if ([drawingCpanel useAreaSwitch].on) {
            mode = 1;
        }
        [canvas setMode:mode];
        [drawingCpanel setCanvas:canvas];
        [[drawingCpanel allowDrawSwitch] setEnabled:TRUE];
        [[drawingCpanel useAreaSwitch] setEnabled:FALSE];
		[self.view addSubview:canvas];
	}
	else {
        // This block is for ENDING a drawing session
		alertViewTrash = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TrashAlertTitle", @"") message:NSLocalizedString(@"TrashAlertMessage", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"") otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
        [alertViewTrash show];
	}
}

- (IBAction)doneItemPressed:(id)sender {
    
    if (!DRAWING) {
        [self drawButtonPressed];
    } else {
        [self allowMoveButtonPressed:allowMoveButton];
    }
}

- (void)removeCanvas {
    
    [drawButton setSelected:FALSE];
    [mapViewDelegate removeAllPins];
    [mapViewDelegate setMainCanvas:nil];
    
    if (canvas!=nil) {
        if (drawCpanelIsEnabled) {
            [self setShowDrawCpanel:FALSE];
        }
        
        [canvas aboutToBeRemoved];
        [canvas removeFromSuperview];
        canvas= nil;
        [[drawingCpanel allowDrawSwitch] setOn:TRUE];
        [[drawingCpanel allowDrawSwitch] setEnabled:FALSE];
        [[drawingCpanel useAreaSwitch] setEnabled:TRUE];
        [doneItem setTitle:NSLocalizedString(DEFAULT_DONE_ITEM_TITLE, @"")];
        [doneItem setTintColor:doneItemDefaultColor];
        drawItem.image = [UIImage imageNamed:@"103-map.png"];
        drawItem.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        
        if ([allowMoveButton isEnabled]) {
            [drawingCpanel allowDrawToggle];
            [allowMoveButton setEnabled:FALSE];
        }
        
        void (^_animations)(void) = ^(void) {
            [searchBar setAlpha:1.0f];
            [searchBar setUserInteractionEnabled:TRUE];
            //map_view setFrame:CGRectMake(map_view.frame.origin.x, searchBar.frame.origin.y + searchBar.frame.size.height, map_view.frame.size.width, map_view.frame.size.height - searchBar.frame.size.height)];
            [undoButton setAlpha:0.0f];
        };
        [UIView animateWithDuration:0.25f animations:_animations];
    }
}

- (void)setShowDrawCpanel:(BOOL)_show {
    
    if (_show && !drawCpanelIsVisible) {
        // Reveal control menu if asked to and if it's not visible
        
        if (drawingCpanel == nil) {
            drawingCpanel = [[DrawingCpanelView alloc] initWithFrame:CGRectMake(0, map_view.frame.origin.y, map_view.frame.size.width, HEIGHT_OF_DRAW_CPANEL)];
            [self.view addSubview:drawingCpanel];
            [drawingCpanel setCanvas:canvas];
            [drawingCpanel setMap_view:map_view];
        }
        
        CGPoint MapViewOrigin = map_view.frame.origin;
        [drawingCpanel setFrame:CGRectMake(drawingCpanel.frame.origin.x, MapViewOrigin.y, drawingCpanel.frame.size.width, HEIGHT_OF_DRAW_CPANEL)];
        
        [self.view sendSubviewToBack:drawingCpanel];
        void (^_animations)(void) = ^(void) {
            [map_view setFrame:CGRectMake(0, MapViewOrigin.y + HEIGHT_OF_DRAW_CPANEL, map_view.frame.size.width, map_view.frame.size.height - HEIGHT_OF_DRAW_CPANEL)];
            [canvas setIsAnimating:TRUE];
            [canvas setFrame:map_view.frame];
        };
        void (^_animation_completed)(BOOL) = ^(BOOL actuallyDone) {
            
            [canvas setIsAnimating:FALSE];
            [canvas setNeedsDisplay];
        };
        [UIView animateWithDuration:0.5f animations:_animations completion:_animation_completed];
        
        drawCpanelIsVisible = TRUE;
        [drawingCpanel setIsVisibleInMainView:TRUE];
        
    } else if (!_show && drawCpanelIsVisible) {
        
        void (^_animations)(void) = ^(void) {
			[map_view setFrame:CGRectMake(0, map_view.frame.origin.y - HEIGHT_OF_DRAW_CPANEL, map_view.frame.size.width, map_view.frame.size.height + HEIGHT_OF_DRAW_CPANEL)];
            [drawingCpanel setFrame:CGRectMake(drawingCpanel.frame.origin.x, drawingCpanel.frame.origin.y, drawingCpanel.frame.size.width, 0.0)];
            [canvas setIsAnimating:TRUE];
            [canvas setFrame:map_view.frame];
		};
        void (^_animation_completed)(BOOL) = ^(BOOL actuallyDone) {
            
            [canvas setIsAnimating:FALSE];
            [canvas setNeedsDisplay];
        };
		[UIView animateWithDuration:0.5f animations:_animations completion:_animation_completed];
        
        drawCpanelIsVisible = FALSE;
        [drawingCpanel setIsVisibleInMainView:FALSE];
    }
    
    [canvas setNeedsDisplay];
}

- (IBAction)locationButtonPressed {
	
	if (map_view.region.span.latitudeDelta>1 && [[location_manager location] horizontalAccuracy]<10000) {
		[map_view setRegion:MKCoordinateRegionMakeWithDistance([[location_manager location] coordinate], 5000, 6000)];
	}
	else {
		[map_view setCenterCoordinate:[[location_manager location] coordinate]];
	}
}

- (IBAction)infoButtonPressed {
	
	[searchBar resignFirstResponder];
	if (config_view==nil) {
		config_view= [MapDistanceConfigButtonView alloc];
		[config_view setLanguage:language];
		config_view= [config_view initWithFrame:CGRectMake(0, map_view.frame.origin.y, map_view.frame.size.width, 0)];
		[config_view setView_controller:self];
        [config_view setAutoresizingMask:UIViewAutoresizingNone];
		[self.view addSubview:config_view];
		[self.view bringSubviewToFront:config_view];
		[drawButton setEnabled:FALSE];
        
        NSInteger newWidth = MIN(320.0, map_view.frame.size.width);
        NSInteger newHeight = MIN(480.0, map_view.frame.size.height);
        //NSLog(@"Map: (%f, %f) x (%f, %f)", map_view.frame.origin.x, map_view.frame.origin.y, map_view.frame.size.width, map_view.frame.size.height);
		
		void (^_animations)(void) = ^(void) {
			[config_view setFrame:CGRectMake(map_view.frame.origin.x + map_view.frame.size.width/2 - newWidth/2, map_view.frame.origin.y + map_view.frame.size.height/2 - newHeight/2, newWidth, newHeight)];
			[drawButton setAlpha:0.25f];
		};
		[UIView animateWithDuration:0.5f animations:_animations];
	}
	else {
        [self infoButtonViewCloseButtonPressed];
	}

}

- (void)infoButtonViewCloseButtonPressed {
	
	void (^_animations)(void) = ^(void) {
        [config_view setAlpha:0.0f];
        [drawButton setEnabled:TRUE];
		[drawButton setAlpha:1.0f];
	};
    
    void (^_animation_completed)(BOOL) = ^(BOOL is_completed) {
        [config_view removeFromSuperview];
        config_view = nil;
    };
    
    if (canvas != nil) {
        BOOL mapMoveAutomatically = [[config_view automaticScrollSwitch] isOn];
        [canvas setUseAutomaticScroll:mapMoveAutomatically];
        [canvas setNeedsDisplay];
    }
	
	[UIView animateWithDuration:0.35f animations:_animations completion:_animation_completed];    
}

- (IBAction)undoButtonPressed {
	
    [self performUndo];
	//modeSelectorView = [[[NSBundle mainBundle] loadNibNamed:@"MapDistanceViewSelectorView" owner:self options:nil] objectAtIndex:0];
    //[map_view addSubview:modeSelectorView];
}

- (IBAction)pinButtonPressed:(id)sender {
    
    [self addPin:1 andCoord:CLLocationCoordinate2DMake(0.0, 0.0) andS1:nil andS2:nil];
}

- (void)addPin:(NSInteger)choice andCoord:(CLLocationCoordinate2D)_coord andS1:(NSString *)_str1 andS2:(NSString *)_str2 {
    if (choice == 1) {
        MapDistancePersistentOverlayView *oview = [mapViewDelegate mapOverlayView];
        PixelLocation *pixelLocation;
        CGPoint center, mapPoint;
        
        if (canvas != nil) {
            center = [oview center];
            mapPoint = [oview convertPoint:center toView:canvas];
            [self allowMoveButtonPressed:allowMoveButton];
            pixelLocation = [canvas addPointToPathAtViewPoint:mapPoint];
            [self allowMoveButtonPressed:allowMoveButton];
        } else {
            [self drawButtonPressed];
            center = [oview center];
            mapPoint = [oview convertPoint:center toView:canvas];
            pixelLocation = [canvas addPointToPathAtViewPoint:mapPoint];
            [self allowMoveButtonPressed:allowMoveButton];
        }
        MKPointAnnotation * pa = [mapViewDelegate addPinToMap:[map_view convertPoint:mapPoint toCoordinateFromView:canvas] andS1:nil andS2:nil];
        [pixelLocation setMapViewPin:pa];
    }
    if (choice == 2) {
        PixelLocation *pixelLocation;
        if (canvas == nil) {
            [self drawButtonPressed];
        } else {
            [self allowMoveButtonPressed:allowMoveButton];
        }
        pixelLocation = [canvas addCoordinateToPath:_coord withGC:TRUE];
        [self allowMoveButtonPressed:allowMoveButton];
        
        MKPointAnnotation *pa = [mapViewDelegate addPinToMap:_coord andS1:_str1 andS2:_str2];
        [pixelLocation setMapViewPin:pa];
    }
}

- (void)orientationChanged:(NSNotification *)note {
    
    orChangedNote = note;
    [orChangedNote retain];
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(orientationChangedTimer) userInfo:nil repeats:FALSE];
}

- (void)refreshUnits {
    [mapScaleView setNeedsDisplay];
    if (canvas != nil) {
        [canvas setNeedsLayout];
        [canvas setNeedsDisplay];
    }
    UILabel *areaLabel = [drawingCpanel areaLabel];
    [areaLabel setText:[canvas stringForDistanceOrArea:0.0]];
}

- (void)orientationChangedTimer {
    
    UIDevice *cd = [orChangedNote object];
    UIDeviceOrientation o = [cd orientation];
    [mapViewDelegate orientationChanged:o];
    if (canvas != nil) {
        //[canvas setFrame:map_view.frame];
        [canvas setNeedsDisplay];
        [canvas setNeedsLayout];
    }
    
    NSInteger newWidth = MIN(320.0, map_view.frame.size.width);
    NSInteger newHeight = MIN(480.0, map_view.frame.size.height);
    if (config_view != nil) {
        void (^_animations)(void) = ^(void) {
            [config_view setFrame:CGRectMake(map_view.frame.origin.x + map_view.frame.size.width/2 - newWidth/2, map_view.frame.origin.y + map_view.frame.size.height/2 - newHeight/2, newWidth, newHeight)];
            [drawButton setAlpha:0.25f];
        };
        [UIView animateWithDuration:0.5f animations:_animations];
    }
    [config_view setScrollEnabled:(config_view.frame.size.height < CONFIG_SETTINGS_CONTENT_HEIGHT)];
}

- (void)performUndo {
    
    if (canvas!=nil) {
		if ([canvas undo:1] == 0) {
            [self removeCanvas];
            [undoButton setAlpha:0.0f];
        }
        //Refresh the map display of drawing path
        [self doneItemPressed:self];
        [self doneItemPressed:self];
	} else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UndoButtonMessageTitle", @"") message:NSLocalizedString(@"UndoButtonMessage", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)settingsButtonPressed:(id)sender {
    
    [searchBar resignFirstResponder];
    if (drawCpanelIsVisible) {
        [self setShowDrawCpanel:FALSE];
    } else {
        [self setShowDrawCpanel:TRUE];
    }
}

- (IBAction)zoomOutMap:(id)sender {
    [map_view setRegion:MKCoordinateRegionMake(map_view.centerCoordinate, MKCoordinateSpanMake(map_view.region.span.latitudeDelta*2.0, map_view.region.span.longitudeDelta*2.0))];
}

- (IBAction)addMeas:(id)sender {
    if (canvas != nil) {
        [canvas addNewMeasurement];
    }
}

// Handles pauses and restarts of drawing a path on the map
- (IBAction)allowMoveButtonPressed:(id)sender {
    
    UISwitch *allowDrawSwitch = [drawingCpanel allowDrawSwitch];
    if (allowDrawSwitch.on) {
        /* Switch so drawing is not allowed, moving is */
        // PAUSE
        // PAUSE
        // PAUSE
        [allowDrawSwitch setOn:FALSE animated:YES];
        [allowMoveButton setSelected:TRUE];
        [drawingCpanel allowDrawToggle];
        
        [doneItem setTitle:NSLocalizedString(@"Draw", @"")];
        [doneItem setTintColor:doneItemDrawColor];
    } else {
        /* Switch so drawing IS allowed */
        // DRAW
        // DRAW
        // DRAW
        [allowDrawSwitch setOn:TRUE animated:YES];
        [allowMoveButton setSelected:FALSE];
        [drawingCpanel allowDrawToggle];
        
        [doneItem setTitle:NSLocalizedString(DONE_BUTTON_TEXT, @"")];
        [doneItem setTintColor:doneItemDoneColor];
    }
}

- (void)searchResultReturnedLocation:(MKCoordinateRegionWrapper *)location {
    
    if ([[location string1] compare:@"DEBUG_DEBUG_DEBUG"]==NSOrderedSame) {
        [zoomOutButton setHidden:FALSE];
        return;
    }
    
    searchDidReturnAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Search Results", @"") message:[NSString stringWithFormat:@"%@\n%@", [location string1], [location string2]] delegate:self cancelButtonTitle:NSLocalizedString(@"Add Pin to Map", @"") otherButtonTitles:NSLocalizedString(@"Find on Map", @""), NSLocalizedString(@"Add Pin and Find", @""), nil];
    [searchDidReturnAlertView show];
        
    lastReturnedSearchLocation = location;
    [searchBar resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == alertViewIntro) {
        LabelWithAction *startHereLabel = [[LabelWithAction alloc] initWithFrame:CGRectMake(0, map_view.frame.size.height - 35, 100, 35)];
        [startHereLabel setText:NSLocalizedString(@"StartHere", @"")];
        [startHereLabel setTextAlignment:NSTextAlignmentCenter];
        [startHereLabel setAdjustsFontSizeToFitWidth:TRUE];
        [startHereLabel setBackgroundColor:[UIColor yellowColor]];
        [startHereLabel setTextColor:[UIColor redColor]];
        [startHereLabel setDeleteTimerWithSeconds:7.5];
        [map_view addSubview:startHereLabel];
    }
    
    if (alertView == searchDidReturnAlertView) {
        if (buttonIndex == 0 || buttonIndex == 2) {
            
            NSString *title = lastReturnedSearchLocation.string1;
            NSString *subtitle = lastReturnedSearchLocation.string2;
            [self addPin:2 andCoord:lastReturnedSearchLocation.region.center andS1:title andS2:subtitle];
        }
        
        if (buttonIndex == 1 || buttonIndex == 2) {
            [lastReturnedSearchLocation toLog];
            MKCoordinateRegion r = [map_view regionThatFits:lastReturnedSearchLocation.region];
            [map_view setRegion:r animated:TRUE];
        }
    }
    
    if (alertView == alertViewTrash) {
        if (buttonIndex == 1) {
            [self removeCanvas];
        }
    }
}

- (void)applicationWillResignActive {
	
	;
}

- (void)applicationWillClose {
	
	[self applicationWillResignActive];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorized) {
        map_view.showsUserLocation = TRUE;
        [location_manager startUpdatingLocation];
    }
}

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	 
	 if (interfaceOrientation == UIInterfaceOrientationPortrait 
		 || interfaceOrientation == UIInterfaceOrientationLandscapeLeft
		 || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		 
		 return YES;
	 } else {
         return NO;
     }
 }

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
