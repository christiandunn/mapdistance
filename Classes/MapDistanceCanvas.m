//
//  MapDistanceCanvas.m
//  MapDistance
//
//  Created by Christian Dunn on 12/19/10.
//  Copyright 2010 Christian Dunn / Cornell University. All rights reserved.
//

#import "MapDistanceCanvas.h"


@implementation MapDistanceCanvas

@synthesize drawing_path;
@synthesize coordinate;
@synthesize boundingMapRect;
@synthesize mode;
@synthesize isAnimating;
@synthesize distance;
@synthesize area;
@synthesize pointsOfPolygon;
@synthesize pointOfIntersection;
@synthesize drawing_cpanel_view;
@synthesize useAutomaticScroll;
@synthesize lastDrawnTopBarString;
@synthesize innerPolygon;

@synthesize mapView;
@synthesize language;

/* Look into re-implementing the path drawing with Breadcrumb */
/* Look into drawing path with overlays instead of Core Graphics */
/* Look into displaying text with one label at all times */

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        stateManager = [[MapDistanceCanvasStateManager alloc] init];
        [stateManager setCanvasStatus:0];
        
        drawing_path= nil;
		self.opaque= FALSE;
		map_moving= 0;
		user_defaults= [NSUserDefaults standardUserDefaults];
        [user_defaults synchronize];
		current_device= [UIDevice currentDevice];
        mode = 0;
        area = -1.0;
        distance = 0;
        isAnimating = FALSE;
        prev_meas_distance = 0;
        prev_meas_area = 0;
        pointsOfPolygon = NSMakeRange(-1, 0);
        pointOfIntersection = nil;
        frozen = FALSE;
        isBeingInteractedWith = FALSE;
        demandsAreaCalculation = FALSE;
        topBarString = nil;
        polygon_intersect = CGPointZero;
        measurementsCount = 0;
        
        /* MKOverlay items */
        coordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
        boundingMapRect = MKMapRectMake(0.0f, 0.0f, 1.0f, 1.0f);
        
        /* Configuration items */
        useAutomaticScroll = [user_defaults boolForKey:@"UseAutomaticScroll"];
        
        /* Top bar label */
        topBarLabel = [[LabelWithAction alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, HEIGHT_OF_DISTANCE_TEXT)];
        NSInvocation *labelAction = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(topLabelActivated)]];
        [labelAction setSelector:@selector(topLabelActivated)];
        [labelAction setTarget:self];
        [topBarLabel setLabelTapInvocation:labelAction];
        [topBarLabel setBackgroundColor:[UIColor whiteColor]];
        [topBarLabel setTextColor:COLOR_SCHEME_2];
        topBarLabel.layer.borderColor = COLOR_SCHEME_2.CGColor;
        topBarLabel.layer.borderWidth = 2;
        [topBarLabel setHidden:TRUE];
        [topBarLabel setUserInteractionEnabled:TRUE];
        [topBarLabel setAdjustsFontSizeToFitWidth:TRUE];
        [topBarLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:topBarLabel];
        
        // Tutorial view goes here:
        // Tutorial view provides some explanation after the user presses "Draw"
        colorTranspar = COLOR_TRANSPAR;
        colorTransparRed = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.25];
        [colorTranspar retain];
        [colorTransparRed retain];
        
        UIViewAutoresizing margins = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        
        drawTutorialBackView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 155.0, self.frame.size.height/2 - 110, 310, 140)];
        [drawTutorialBackView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
        [self addSubview:drawTutorialBackView];
        
        nf = [[NSNumberFormatter alloc] init];
        [nf setUsesGroupingSeparator:TRUE];
        [nf setUsesSignificantDigits:TRUE];
        [nf setMaximumSignificantDigits:4];
        [nf setMinimumSignificantDigits:0];
       
        // Tutorial view label
        drawEnabledLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 150.0, self.frame.size.height/2 - 100, 300, 30)];
        [drawEnabledLabel setText:NSLocalizedString(@"NowDrawPathOnMap", @"")];
        [drawEnabledLabel setBackgroundColor:colorTranspar];
        [drawEnabledLabel setTextAlignment:NSTextAlignmentCenter];
        [drawEnabledLabel setAutoresizingMask:margins];
        [self addSubview:drawEnabledLabel];
        
        // Tutorial view icon
        drawEnabledIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"path.png"]];
        [drawEnabledIcon setFrame:CGRectMake(self.frame.size.width/2 - 38.0, self.frame.size.height/2- 14.0, 76.0, 27.0)];
        [drawEnabledIcon setAlpha:0.25f];
        [drawEnabledIcon setUserInteractionEnabled:FALSE];
        [drawEnabledIcon setAutoresizingMask:margins];
        [self addSubview:drawEnabledIcon];
        timerForDrawEnabledAnimator = [NSTimer scheduledTimerWithTimeInterval:0.50f target:self selector:@selector(drawEnabledIconAnimator) userInfo:nil repeats:TRUE];
        
        // Tutorial view "move map" explanation
        moveMapTutorialView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 150.0, self.frame.size.height/2 - 60, 300, 32)];
        mapMoveTutorialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 5.0, moveMapTutorialView.frame.size.width - 10.0, 21.0)];
        NSString *str = [NSString stringWithFormat:@"%@ '%@' %@", NSLocalizedString(@"TutLabelMapMove1", @""), NSLocalizedString(DONE_BUTTON_TEXT, @""), NSLocalizedString(@"TutLabelMapMove2", @"")];
        [mapMoveTutorialLabel setTextAlignment:NSTextAlignmentCenter];
        [mapMoveTutorialLabel setUserInteractionEnabled:FALSE];
        [mapMoveTutorialLabel setAdjustsFontSizeToFitWidth:TRUE];
        [mapMoveTutorialLabel setBackgroundColor:colorTranspar];
        [mapMoveTutorialLabel setText:str];
        [mapMoveTutorialLabel setAutoresizingMask:margins];
        [moveMapTutorialView addSubview:mapMoveTutorialLabel];
        [moveMapTutorialView setAutoresizingMask:margins];
        [self addSubview:moveMapTutorialView];
        
        button_continue = nil;
        areaCalculatedInvocation = nil;
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self setClipsToBounds:TRUE];
    }
    return self;
}

void centerTextInContextAtOrigin(
								 CGContextRef cgContext,
								 CGFloat x, CGFloat y,
								 const  char *fontName,
								 float textSize,
								 const char *text)
{
	CGContextSaveGState(cgContext);
	CGContextSelectFont(cgContext, fontName,
						textSize, kCGEncodingMacRoman);
	
	// Save the GState again for the text drawing mode
	CGContextSaveGState(cgContext);
	CGContextSetTextDrawingMode(cgContext, kCGTextInvisible);
	CGContextShowTextAtPoint(cgContext, 0, 0, text, strlen(text));
	CGContextRestoreGState(cgContext);
	
	// Draw the text
	CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    CGContextSetTextMatrix(cgContext, transform);
    UIColor *cs2 = COLOR_SCHEME_2;
    CGFloat *color = malloc(sizeof(CGFloat)*4);
    [cs2 getRed:&color[0] green:&color[1] blue:&color[2] alpha:&color[3]];
	CGContextSetFillColor(cgContext, color);
	CGContextShowTextAtPoint(cgContext,
							 x, y+(textSize/2), text, strlen(text));
	
	CGContextRestoreGState(cgContext);
}

- (void)drawTopLabel:(NSString *)str {
    
    [topBarLabel setHidden:FALSE];
    [topBarLabel setText:str];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];

    [topBarLabel setFrame:CGRectMake(0, 0, self.frame.size.width, HEIGHT_OF_DISTANCE_TEXT)];
    
    
    if (button_continue != nil) {
        [button_continue setFrame:CGRectMake(button_continue.frame.origin.x, button_continue.frame.origin.y, self.frame.size.width - 2*MAP_MARGIN, button_continue.frame.size.height)];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    	
    CGContextRef c = UIGraphicsGetCurrentContext();
    [topBarLabel setHidden:TRUE];
    
    /* Draw the green representation of area found on a map */
    if (pointsToFill != nil && mode == 1 && !isAnimating) {
        for (int i=0; i<[pointsToFill count]; i++) {
            //TODO: Make green rectangle drawing more efficient with polygon method
            //TODO: Implement Apple's forward geocoder, CLGeocoder
            //TODO: Add Chinese language support
            PixelLocation *latlon = [pointsToFill objectAtIndex:i];
            CLLocationCoordinate2D latlonCoord = CLLocationCoordinate2DMake(latlon.latitude, latlon.longitude);
            CGPoint convertedPoint = [mapView convertCoordinate:latlonCoord toPointToView:self];
            CGContextSetAlpha(c, 0.5f);
            CGContextSetStrokeColorWithColor(c, [[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.25f] CGColor]);
            CGContextStrokeRect(c, CGRectMake(convertedPoint.x, convertedPoint.y, 1.0, 1.0));
            CGContextSetAlpha(c, 1.0f);
        }
    }
	
    /* Drawing a path */
    /* Draw the path if the canvas status equals 2 (drawing mode) OR drawPathAnyways is TRUE.
     drawPathAnyways is TRUE if (1) the touch had ended but a new location to start drawing the path
     is being looked for. */
    CGPoint pt, pt1;
    if (drawing_path!=nil && [drawing_path count]>0) {
        /* Actually draw the path */
        PixelLocation *px;
        px= [drawing_path objectAtIndex:0];
        //The very first point in the drawing path
        pt1 = [mapView convertCoordinate:CLLocationCoordinate2DMake(px.latitude, px.longitude) toPointToView:self];
        CGContextMoveToPoint(c, pt1.x, pt1.y);
        for (NSInteger i=1; i<[drawing_path count]; i+=1) {
            px= [drawing_path objectAtIndex:i];
            pt= [mapView convertCoordinate:CLLocationCoordinate2DMake(px.latitude, px.longitude) toPointToView:self];
            CGContextAddLineToPoint(c, pt.x, pt.y);
        }
        
        CGContextSetLineWidth(c, 2.00);
        CGContextSetStrokeColorWithColor(c, [[UIColor colorWithRed:1.0f green:0.1 blue:0.1f alpha:0.9f] CGColor]);
        CGContextDrawPath(c, kCGPathStroke);
        
        // If there is only one point then we still want that point to be visible:
        if ([drawing_path count] == 1) {
            CGContextStrokeEllipseInRect(c, CGRectMake(pt1.x-3, pt1.y-3, 6, 6));
        }
        
        /* Draw the margins */
        if (useAutomaticScroll) {
            int height = self.frame.size.height;
            int width = self.frame.size.width;
            int yOffsetTop = (int)((y_offset < 0) ? - MAP_MARGIN : y_offset);
            int yOffsetBottom = (int)((y_offset > 0) ? MAP_MARGIN : y_offset);
            //Draw border rectangles on the margin of the canvas
            CGContextSetFillColorWithColor(c, [[UIColor blackColor] CGColor]);
            CGContextSetAlpha(c, 0.35f);
            //Left
            CGContextFillRect(c, CGRectMake(0, 0, MAP_MARGIN, height));
            //Right
            CGContextFillRect(c, CGRectMake(width - MAP_MARGIN, 0, MAP_MARGIN, height));
            //Top
            CGContextFillRect(c, CGRectMake(MAP_MARGIN, 0, width - MAP_MARGIN*2, MAP_MARGIN + 20 + yOffsetTop));
            //Bottom
            CGContextFillRect(c, CGRectMake(MAP_MARGIN, height - MAP_MARGIN + yOffsetBottom, width - MAP_MARGIN*2, MAP_MARGIN + abs((int)y_offset)));
        }
        CGContextSetAlpha(c, 1.0f);
    }
    
    /* Blue line for resuming path drawing */
    double distance_delta = 0.0;
    if ([stateManager getCanvasStatus] == 1 && drawing_path!=nil && [drawing_path count]>0) {
        if ([drawing_path count]==1) {
            pt = pt1;
        }
        if ([drawing_path count]>0) {
            CGContextMoveToPoint(c, pt.x, pt.y);
            CGContextAddLineToPoint(c, cursor_pixel.x, cursor_pixel.y + y_offset);
            CGContextSetStrokeColorWithColor(c, [[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.9f] CGColor]);
            CGContextDrawPath(c, kCGPathStroke);
            
            CLLocationCoordinate2D coord1 = [mapView convertPoint:pt toCoordinateFromView:self];
            CLLocationCoordinate2D coord2 = [mapView convertPoint:CGPointMake(cursor_pixel.x, cursor_pixel.y + y_offset) toCoordinateFromView:self];
            distance_delta = calculateDistance(coord1.latitude, coord1.longitude, coord2.latitude, coord2.longitude);
        }
    }
    
    /* Little cursor */
	if ([stateManager getCanvasStatus] == 1) {
		
		NSInteger x_val= (NSInteger)cursor_pixel.x;
		NSInteger y_val= (NSInteger)cursor_pixel.y + y_offset;
		UIColor *cursor_color1= [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f];
		UIColor *cursor_color2= [UIColor colorWithRed:(153.0/255.0) green:1.0f blue:1.0f alpha:1.0f];
		CGContextSetFillColorWithColor(c, [cursor_color2 CGColor]);
		CGContextSetStrokeColorWithColor(c, [cursor_color1 CGColor]);
		CGContextFillEllipseInRect(c, CGRectMake(x_val - 2, y_val - 2, 4, 4));
		CGContextStrokeEllipseInRect(c, CGRectMake(x_val - 2, y_val - 2, 4, 4));
        
        NSInteger thickness = 4;
        CGContextStrokeRect(c, CGRectMake(x_val - 75.0, y_val + thickness/2, 50.0, thickness));
        CGContextStrokeRect(c, CGRectMake(x_val + 25.0, y_val + thickness/2, 50.0, thickness));
        CGContextStrokeRect(c, CGRectMake(x_val - thickness/2, y_val + 25.0, thickness, 50.0));
        CGContextStrokeRect(c, CGRectMake(x_val - thickness/2, y_val - 75.0, thickness, 50.0));
	}
    
    // Draw the little dot where the area polygon self intersects itself
    /*
    if ((polygon_intersect.x != 0 || polygon_intersect.y != 0) && mode == 1) {
        CGContextSetStrokeColorWithColor(c, [[UIColor blackColor] CGColor]);
        CGContextSetFillColorWithColor(c, [[UIColor whiteColor] CGColor]);
        CGContextFillEllipseInRect(c, CGRectMake(polygon_intersect.x - 2, polygon_intersect.y - 2, 4, 4));
		CGContextStrokeEllipseInRect(c, CGRectMake(polygon_intersect.x - 2, polygon_intersect.y - 2, 4, 4));
    }
     */
    
    /*
    if ([stateManager canvasIsEditingPath]) {
        [self calculateDistance];
    }
     */
    
	if (drawing_path!=nil && [drawing_path count]>0) {
        if (drawing_path!=nil) {

            /* Draw the text for how many miles the path is */
			CGContextSetLineWidth(c, 2);
			CGContextSetStrokeColorWithColor(c, [[UIColor colorWithRed:1.0f green:0.1 blue:0.1f alpha:1.0f] CGColor]);
			CGContextSetFillColorWithColor(c, [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] CGColor]);
			//CGContextFillRect(c, CGRectMake(0, 0, self.frame.size.width, HEIGHT_OF_DISTANCE_TEXT));
			//CGContextStrokeRect(c, CGRectMake(0, 0, self.frame.size.width, HEIGHT_OF_DISTANCE_TEXT));
			
			NSString *draw_text_string = [self stringForDistanceOrArea:distance_delta];
            
            lastDrawnTopBarString = [draw_text_string copy];
            [lastDrawnTopBarString retain];
            [self drawTopLabel:draw_text_string];
            //centerTextInContextAtOrigin(c, 5, 8, "Helvetica", 14, [draw_text_string UTF8String]);
		}
	}
	
}

- (double)calculateDistance {
    
    distance = prev_meas_distance;
    if (mode == 0) {
        //Recalculate the approximate distance of the path drawn by the pixels
        for (NSInteger i=1; i<[drawing_path count]; i+=1) {
            PixelLocation *pt1= [drawing_path objectAtIndex:(i-1)];
            PixelLocation *pt2= [drawing_path objectAtIndex:i];
            
            distance= distance + calculateDistance(pt1.latitude, pt1.longitude, pt2.latitude, pt2.longitude);
        }
        if (measurementsCount == 0) {
            measurementsCount = 1;
        }
    }
    return distance;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (frozen) {
        return;
    }
    
    if ([findAreaThread isExecuting]) {
        [findAreaThread cancel];
        if (pointsToFill != nil) {
            [pointsToFill removeAllObjects];
            pointsToFill = nil;
        }
    }
    
    isBeingInteractedWith = TRUE;
    
    map_moving= 0;
	y_offset= [user_defaults integerForKey:@"pixel_offset"];
    
    UITouch *t = [touches anyObject];
    CGPoint tp = [t locationInView:self];
    if (tp.x >= self.frame.size.width - MAP_MARGIN) {
        NSLog(@"Move Map Right");
        return;
    }
	
    /* Initialization phase with a y-offset */
	if ([stateManager getCanvasStatus] == 0 && y_offset != 0) {
		
		UITouch *input_event= [touches anyObject];
		
		cursor_pixel= [input_event locationInView:self];
		cursor_pixel.y= cursor_pixel.y + y_offset;
		
		[self setNeedsDisplay];
		[self configureCanvasForDrawing];
		
		return;
	}
    
    if ([stateManager getCanvasStatus]==1) {
		
		UITouch *input_event= [touches anyObject];
		CGPoint cursor_pixel2= [input_event locationInView:self];
		cursor_pixel= cursor_pixel2;
		cursor_pixel.y= cursor_pixel.y + y_offset;
		
		[self setNeedsDisplay];
	}
		
    /* If in full on path drawing mode OR no path has been started and there's no y-offset */
	if ([stateManager canvasIsEditingPath] || (y_offset==0 && [stateManager getCanvasStatus]==0)) {
		UITouch *input_event= [touches anyObject];
		[stateManager setCanvasStatus:2];
				
		CGPoint pixel_location= [input_event locationInView:self];
		first_pixel= pixel_location;
		first_pixel.y= first_pixel.y + y_offset;
        
        CLLocationCoordinate2D location= [mapView convertPoint:first_pixel toCoordinateFromView:self];
        [self addCoordinateToPath:location withGC:TRUE];
		
		[self setNeedsDisplay];
	}
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (frozen) {
        return;
    }
    
    if ([findAreaThread isExecuting]) {
        [findAreaThread cancel];
        if (pointsToFill != nil) {
            [pointsToFill removeAllObjects];
            pointsToFill = nil;
        }
    }
    
    if (area > 0) {
        return;
    }
	
    NSInteger yOffsetTop = (y_offset < 0) ? - MAP_MARGIN : y_offset;
    NSInteger yOffsetBottom = (y_offset > 0) ? MAP_MARGIN : y_offset;
    
	if ([stateManager getCanvasStatus]==1) {
		
		UITouch *input_event= [touches anyObject];
		CGPoint cursor_pixel2= [input_event locationInView:self];
		cursor_pixel= cursor_pixel2;
		cursor_pixel.y= cursor_pixel.y + y_offset;
		
		[self setNeedsDisplay];
	}
	
	if ([stateManager getCanvasStatus] > 0) {
		if (map_moving==1) {
			return;
		}
		
		if (drawing_path!=nil) {
			;
		}
		else {
			//If drawing path is equal to nil:
			drawing_path= [NSMutableArray arrayWithCapacity:100];
			[drawing_path retain];
		}
		
		UITouch *input_event= [touches anyObject];
		CGPoint pixel_location= [input_event locationInView:self];
        cursor_pixel = pixel_location;
		pixel_location.y= pixel_location.y + y_offset;
		
		if ([stateManager getCanvasStatus] > 0 && useAutomaticScroll) {
			//Move the map if necessary
            CLLocationCoordinate2D newMapCenterCoordinate;
            double newMapCenterLatitude;
            double newMapCenterLongitude;
            BOOL didMoveMap = FALSE;
			if (pixel_location.x < MAP_MARGIN) {
                newMapCenterLatitude = mapView.centerCoordinate.latitude;
                newMapCenterLongitude = mapView.centerCoordinate.longitude - (mapView.region.span.longitudeDelta/2);
                didMoveMap = TRUE;
			}
			if (pixel_location.x > self.frame.size.width - MAP_MARGIN) {
				newMapCenterLatitude = mapView.centerCoordinate.latitude;
                newMapCenterLongitude = mapView.centerCoordinate.longitude + (mapView.region.span.longitudeDelta/2);
                didMoveMap = TRUE;
			}
			if (pixel_location.y < MAP_MARGIN + 20 + yOffsetTop) {
                newMapCenterLatitude = mapView.centerCoordinate.latitude + (mapView.region.span.latitudeDelta/2);
				newMapCenterLongitude = mapView.centerCoordinate.longitude;
                didMoveMap = TRUE;
			}
			if (pixel_location.y > self.frame.size.height - MAP_MARGIN + yOffsetBottom) {
				newMapCenterLatitude = mapView.centerCoordinate.latitude - (mapView.region.span.latitudeDelta/2);
				newMapCenterLongitude = mapView.centerCoordinate.longitude;
				didMoveMap = TRUE;
			}
            if (didMoveMap) {
                newMapCenterCoordinate = CLLocationCoordinate2DMake([CMDGreatCircle normalizeLatitude:newMapCenterLatitude], [CMDGreatCircle normalizeLongitude:newMapCenterLongitude]);
                [mapView setCenterCoordinate:newMapCenterCoordinate];
                map_moving = 1;
                [self mapRegionChanged];
                if (newMapCenterLatitude == newMapCenterCoordinate.latitude) {
                    return;
                }
            }
		}

        if ([stateManager canvasIsEditingPath]) {
            CLLocationCoordinate2D location= [mapView convertPoint:pixel_location toCoordinateFromView:self];
            [self addCoordinateToPath:location withGC:FALSE];
        }
	}
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (frozen) {
        return;
    }
    
    isBeingInteractedWith = FALSE;
    
    // If a path is being drawn when the touch ends, and the mode is distance find or area find
    if ([stateManager getCanvasStatus]!=1 && (mode==0 || mode==1)) {
        
        /* These lines of code ensure that, if the user does not select another point before clicking the button, then the path will resume exactly where the path left off */
        UITouch *touch = [touches anyObject];
        cursor_pixel = [touch locationInView:self];
        
        if ([user_defaults boolForKey:@"PauseDrawOnTouchUp"] == TRUE || y_offset != 0) {
            [stateManager setCanvasStatus:1];
            [self mapRegionChanged];
        }
    }
    
    // If area is being found, and we're looking for a place to start a path or currently drawing a path
    // then calculate the area if the touch just ended
    if (mode == 1 && ([stateManager getCanvasStatus] == 1 || [stateManager canvasIsEditingPath])) {
            [self calculateAreaThread];
    }
    
    [self calculateDistance];
    [self setNeedsDisplay];
}

- (BOOL)pathCheckIntersectionAtIndex:(NSInteger)i {
    BOOL intersectsYesNo = FALSE;
    for (int n=1; n<[drawing_path count]; n++) {
        if (labs(n-i)>1) {
            PixelLocation *a1 = [drawing_path objectAtIndex:(i-1)];
            PixelLocation *a2 = [drawing_path objectAtIndex:(i)];
            PixelLocation *b1 = [drawing_path objectAtIndex:(n-1)];
            PixelLocation *b2 = [drawing_path objectAtIndex:(n)];
            intersectsYesNo = intersectsYesNo || [self lineSegmentsIntersect:a1 andPt:a2 andPt:b1 andPt:b2 andIXPtr:NULL andIYPtr:NULL];
        }
    }
    return intersectsYesNo;
}

- (void)calculateAreaThread {
    if (demandsAreaCalculation) {
        topBarString = NSLocalizedString(@"TryingToCalculateArea", @"");
        [self setNeedsDisplay];
        findAreaThread = [[NSThread alloc] initWithTarget:self selector:@selector(calculateAreaPrivate) object:nil];
        [findAreaThread start];
        demandsAreaCalculation = FALSE;
    }
}

- (BOOL)lineSegmentsIntersect:(PixelLocation *)ls1pt1 andPt:(PixelLocation *)ls1pt2 andPt:(PixelLocation *)ls2pt1 andPt:(PixelLocation *)ls2pt2 andIXPtr:(double *)ix andIYPtr:(double *)iy {
    
    CDLineSegment *cdls1 = [[CDLineSegment alloc] init];
    CDLineSegment *cdls2 = [[CDLineSegment alloc] init];
    cdls1.point1 = CGPointMake(ls1pt1.x, ls1pt1.y);
    cdls1.point2 = CGPointMake(ls1pt2.x, ls1pt2.y);
    cdls2.point1 = CGPointMake(ls2pt1.x, ls2pt1.y);
    cdls2.point2 = CGPointMake(ls2pt2.x, ls2pt2.y);
    CDLineSegmentIntersectionResult *pti = [CDVectorMath intersectionOfTwoLineSegments:cdls1 andOther:cdls2];
    
    if (pti.intersects && ix!=NULL && iy!=NULL) {
        *ix = pti.intersection.x;
        *iy = pti.intersection.y;
    }
    
    return pti.intersects;
}

- (void)areaCalculated:(NSNumber *)_area {
    //TODO: Implement multiple area calculations with overlays and allowing another region to be drawn around this point in the program.
    topBarString = nil;
    area = [_area doubleValue] + prev_meas_area;
    if (area > 0) {
        frozen = TRUE;
        if (button_continue != nil) {
            [button_continue removeFromSuperview];
            button_continue = nil;
        }
        if (areaFindMode == 1 || areaFindMode == 0) {
            //Necessary
            [mapView addOverlay:innerPolygon];
        }
        measurementsCount += 1;
    }
    [self setNeedsDisplay];
    if (areaCalculatedInvocation != nil) {
        [areaCalculatedInvocation invoke];
    }
}

- (void)setAreaCalculatedUpdate:(NSInvocation *)inv {
    
    areaCalculatedInvocation = inv;
    [areaCalculatedInvocation retain];
}

- (void)calculateAreaPrivate {
    NSLog(@"Area thread");
    [self calculateOverlay];
    
    /* We need to calculate the width and height of the array that we'll need */
    /* Increase the size of the array of points if any points go off of the current view */
    CLLocationCoordinate2D locOfTopLeft = CLLocationCoordinate2DMake(maxLat, minLon);
    CLLocationCoordinate2D locOfBottomRight = CLLocationCoordinate2DMake(minLat, maxLon);
    CGPoint topLeftOnView = [mapView convertCoordinate:locOfTopLeft toPointToView:self];
    CGPoint bottomRightOnView = [mapView convertCoordinate:locOfBottomRight toPointToView:self];
    NSInteger leftOffset = 0;
    if (topLeftOnView.x < 0) {
        leftOffset = (int)round(fabs(topLeftOnView.x));
    }
    NSInteger rightPush = 0;
    if (bottomRightOnView.x >= self.frame.size.width) {
        rightPush = ((int)(round(bottomRightOnView.x)) - self.frame.size.width + 1);
    }
    NSInteger topOffset = 0;
    if (topLeftOnView.y < 0) {
        topOffset = (int)round(fabs(topLeftOnView.y));
    }
    NSInteger bottomPush = 0;
    if (bottomRightOnView.y >= self.frame.size.height) {
        bottomPush = ((int)(round(bottomRightOnView.y)) - self.frame.size.height + 1);
    }
    NSInteger b = bottomPush;
    
    NSMutableArray *allPointsOnPath = [[NSMutableArray alloc] initWithCapacity:100];
    [allPointsOnPath retain];
    for (int i=0; i<[drawing_path count]; i++) {
        PixelLocation *px = [drawing_path objectAtIndex:i];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(px.latitude, px.longitude);
        CGPoint pt = [mapView convertCoordinate:coord toPointToView:self];
        [allPointsOnPath addObject:[PixelLocation pixelLocationWithX:pt.x andY:pt.y]];
    }
    
    /* Check to see if the path ever intersects itself */
    int fi = -1;    //First point in point set, that intersects
    int fn = -1;    //Last point in point set, that intersects
    double ix = -1; //CanvasCoord-X of intersection
    double iy = -1; //CanvasCoord-Y of intersection
    double iLat = 0.0;  //Intersection Latitude
    double iLon = 0.0;  //Intersection Longitude
    BOOL pathSelfIntersects = FALSE;
    for (int i=1; i<[allPointsOnPath count]; i++) {
        for (int n=(i+1); n<[allPointsOnPath count]; n++) {
            BOOL pathIntersectsYesNo = FALSE; //Whether or not the path intersects at these 2 l.s.'s
            if (pathSelfIntersects == FALSE) {  //Only grab the first intersection
                pathIntersectsYesNo = [self lineSegmentsIntersect:[allPointsOnPath objectAtIndex:(i-1)] andPt:[allPointsOnPath objectAtIndex:i] andPt:[allPointsOnPath objectAtIndex:(n-1)] andPt:[allPointsOnPath objectAtIndex:(n)] andIXPtr:&ix andIYPtr:&iy];
            }
            //Intersection is (fi-1)-----(fi) and (fn-1)-----(fn)
            /* If the line segments are right next to each other, don't say that they "intersect" because they probably don't really. They're probably just right next to each other. */
            if (abs(i - n)<2) {
                pathIntersectsYesNo = FALSE;
            }
            if (pathIntersectsYesNo == TRUE) {
                fi = i;
                fn = n;
                CDLineSegment *ls1 = [CDLineSegment new];
                CDLineSegment *ls2 = [CDLineSegment new];
                PixelLocation *l1p1 = [drawing_path objectAtIndex:(i-1)];
                PixelLocation *l1p2 = [drawing_path objectAtIndex:i];
                PixelLocation *l2p1 = [drawing_path objectAtIndex:(n-1)];
                PixelLocation *l2p2 = [drawing_path objectAtIndex:n];
                ls1.point1 = CGPointMake(l1p1.latitude, l1p1.longitude);
                ls1.point2 = CGPointMake(l1p2.latitude, l1p2.longitude);
                ls2.point1 = CGPointMake(l2p1.latitude, l2p1.longitude);
                ls2.point2 = CGPointMake(l2p2.latitude, l2p2.longitude);
                CLLocationCoordinate2D fll = [CDVectorMath intersectionOfTwoLatLonLineSegments:ls1 andOther:ls2];
                iLat = fll.latitude;
                iLon = fll.longitude;
            }
            pathSelfIntersects = pathIntersectsYesNo || pathSelfIntersects;
        }
    }
    
    /* pathSelfIntersects contains whether or not the path is self intersecting */
    if (pathSelfIntersects) {
        polygon_intersect = CGPointMake(ix, iy);
        //TODO: Fix this
        CLLocationCoordinate2D LatLonOfIntersection = CLLocationCoordinate2DMake(iLat, iLon);
        pointOfIntersection = [PixelLocation pixelLocationWithLatitude:LatLonOfIntersection.latitude    andLongitude:LatLonOfIntersection.longitude];
        
        //pointsOnThisPath will contain Non-Coordinate points from the self-intersecting section
        //Used for rough estimate of area but not for polygon drawing
        NSMutableArray *pointsOnThisPath = [NSMutableArray arrayWithArray:[allPointsOnPath subarrayWithRange:NSMakeRange(fi, fn - fi)]];
        [pointsOnThisPath retain];
        [pointsOnThisPath insertObject:[PixelLocation pixelLocationWithX:(int)ix andY:(int)iy] atIndex:0];
        [pointsOnThisPath addObject:[PixelLocation pixelLocationWithX:(int)ix andY:(int)iy]];
        
        //This sum will contain the area
        double sum = 0;
        
        //Determine how accurate of an area find algorithm to used based on the zoom level
        MKCoordinateRegion mapRect = [mapView region];
        MKCoordinateSpan mapSpan = mapRect.span;
        double maxSpan = MAX(mapSpan.latitudeDelta, mapSpan.longitudeDelta);
        [user_defaults synchronize];
        double latspan = [user_defaults doubleForKey:@"latspan"];
        if (maxSpan < latspan) {
            areaFindMode = 0;
        } else {
            areaFindMode = 3;
        }
        
        CLLocationCoordinate2D origin = [mapView convertPoint:CGPointMake(0.0, 0.0) toCoordinateFromView:self];
        
        if (areaFindMode != 3) {
            for (int i=1; i<[pointsOnThisPath count]; i++) {
                //integral_over_perimeter(-y dx + x dy) for Green's Theorem method
                //In this code, we use the Shoelace Formula for finding area, also
                //known as the Surveyor's Formula.
                
                PixelLocation *pt1 = [pointsOnThisPath objectAtIndex:(i-1)];
                PixelLocation *pt2 = [pointsOnThisPath objectAtIndex:i];
                CGPoint point1 = CGPointMake(pt1.x, pt1.y);
                CGPoint point2 = CGPointMake(pt2.x, pt2.y);
                
                if (areaFindMode == 0) {
                    //TODO: Area Mode set to 1
                    areaFindMode = 1;
                }
                if (areaFindMode == 0) {
                    //The Surveyor's Formula: one element of the total sum
                    sum += point1.x*point2.y - point2.x*point1.y;
                } else if (areaFindMode == 1) {
                    //Slightly more accurate implementation of the Surveyor's Formula
                    //That converts pixel locations to actual distance locations. This
                    //still probably wouldn't work very well for far out zoom levels,
                    //because the curvature of the Earth would render a planar coordinate
                    //system quite inaccurate. For that case, use areaFindMode == 2.
                    CLLocationCoordinate2D coord1 = [mapView convertPoint:point1 toCoordinateFromView:self];
                    CLLocationCoordinate2D coord2 = [mapView convertPoint:point2 toCoordinateFromView:self];
                    double dist1 = calculateDistance(origin.latitude, origin.longitude, coord1.latitude, coord1.longitude);
                    double dist2 = calculateDistance(origin.latitude, origin.longitude, coord2.latitude, coord2.longitude);
                    double newX1 = dist1*cos(atan(point1.y/point1.x));
                    double newY1 = dist1*sin(atan(point1.y/point1.x));
                    double newX2 = dist2*cos(atan(point2.y/point2.x));
                    double newY2 = dist2*sin(atan(point2.y/point2.x));
                    sum += newX1*newY2 - newX2*newY1;
                } else if (areaFindMode == 2) {
                    //Method 2: A point for literally every pixel along the path, along with distance conversion, to better handle the curvature of the Earth. The resulting distance converted region of an originally straight edged region on a rectangular surface should look bulged and curved. at the edges
                    NSLog(@"Error: Method 2 not implemented");
                }
            }
        }
        
        if (areaFindMode == 3) {
            //Method 3: Accurate style, pixel by pixel with flood fill.
            int array_width = self.frame.size.width + leftOffset + rightPush;
            int array_height = self.frame.size.height + topOffset + b;
            [allPointsOnPath removeAllObjects];
            
            int **points;
            points = malloc(array_width * sizeof(int *));
            if (points == NULL) {
                NSLog(@"Out of memory, or other error.\n");
            }
            for (int i=0; i<array_width; i++) {
                points[i] = malloc(array_height * sizeof(int));
                if (points[i] == NULL) {
                    NSLog(@"Out of memory, or other error.\n");
                }
            }
            
            /* For points array: 0 = nothing, 1 = path, 2 = in area, 3 = crawler on area */
            for (int i=0; i<array_width; i++) {
                for (int j=0; j<array_height; j++) {
                    points[i][j] = 0;
                }
            }
            
            for (int i=1; i<[drawing_path count]; i++) {
                /* Create path between the point and the previous point */
                PixelLocation *px1 = [drawing_path objectAtIndex:(i-1)];
                PixelLocation *px2 = [drawing_path objectAtIndex:i];
                CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake(px1.latitude, px1.longitude);
                CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake(px2.latitude, px2.longitude);
                CGPoint pt1 = [mapView convertCoordinate:coord1 toPointToView:self];
                CGPoint pt2 = [mapView convertCoordinate:coord2 toPointToView:self];
                double deltaY = pt2.y - pt1.y;
                double deltaX = pt2.x - pt1.x;
                double vectorMag = sqrt(deltaY*deltaY + deltaX*deltaX);
                double unitVectorX = deltaX / vectorMag;
                double unitVectorY = deltaY / vectorMag;
                
                for (double p=0.0; p<vectorMag; p+=1.0) {
                    [self checkThreadCancel];
                    int px = (int)round(pt1.x + (unitVectorX * p));
                    int py = (int)round(pt1.y + (unitVectorY * p));
                    /* Make sure the array indexes don't go over the array's bounds */
                    if (px > (self.frame.size.width - 1.0)) {
                        px = (int)(self.frame.size.width - 1.0);
                    }
                    if (py > (self.frame.size.height - 1.0)) {
                        py = (int)(self.frame.size.height - 1.0);
                    }
                    points[px+leftOffset][py+topOffset] = 1;
                    [allPointsOnPath addObject:[PixelLocation pixelLocationWithX:(pt1.x + (unitVectorX * p)) andY:(pt1.y + (unitVectorY * p))]];
                }
            }
            
            BOOL doesIntersect = TRUE;
            /* Find the average of the points */
            int sum_x = 0;
            int sum_y = 0;
            for (int i=0; i<[allPointsOnPath count]; i++) {
                PixelLocation *px1 = [allPointsOnPath objectAtIndex:i];
                sum_x += px1.x;
                sum_y += px1.y;
            }
            int average_x = (int)round((double)sum_x / ((double)[allPointsOnPath count]));
            int average_y = (int)round((double)sum_y / ((double)[allPointsOnPath count]));
            
            /* If the path does intersect itself, take the average of the points and try
             to find the area based on that */
            /* 1 = path, 2 = in area, 3 = being crawled */
            /* THIS IS THE MAIN AREA FINDING ALGORITHM */
            BOOL keepgoing = TRUE;
            NSInteger counter = 0;
            NSMutableArray *crawlers = [NSMutableArray arrayWithCapacity:100];
            if (doesIntersect) {
                [crawlers addObject:[PixelLocation pixelLocationWithX:(average_x+leftOffset) andY:(average_y+topOffset)]];
                points[average_x+leftOffset][average_y+topOffset] = 3;
                while (keepgoing) {
                    //TODO: Make faster by keeping a list of the crawlers, instead of searching through the entire array for the crawlers on each step.
                    keepgoing = FALSE;
                    for (int i=0; i<array_width; i++) {
                        for (int j=0; j<array_height; j++) {
                            [self checkThreadCancel];
                            if (points[i][j] == 3) {
                                points[i][j] = 2;
                                if (i < (array_width-1) && points[i+1][j] == 0) {
                                    points[i+1][j] = 3;
                                    keepgoing = TRUE;
                                }
                                if (i > 0 && points[i-1][j] == 0) {
                                    points[i-1][j] = 3;
                                    keepgoing = TRUE;
                                }
                                if (j < (array_height-1) && points[i][j+1] == 0) {
                                    points[i][j+1] = 3;
                                    keepgoing = TRUE;
                                }
                                if (j > 0 && points[i][j-1] == 0) {
                                    points[i][j-1] = 3;
                                    keepgoing = TRUE;
                                }
                            }
                        }
                    }
                    counter += 1;

                    if (counter > 10000) {
                        keepgoing = FALSE;
                        
                        UIAlertView *areaNotCalculatedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Area Not Calculated", @"") message:NSLocalizedString(@"AreaNotCalculatedMessage", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil];
                        [areaNotCalculatedAlert show];
                        [areaNotCalculatedAlert release];
                        
                        area = -1.0;
                    }
                }
            }
            
            /* Calculate the actual area */
            if (doesIntersect) {
                NSInteger points_that_are_in_area = 0;
                if (pointsToFill!=nil) {
                    [pointsToFill release];
                }
                pointsToFill = [NSMutableArray arrayWithCapacity:100];
                [pointsToFill retain];
                double totalArea = 0.0;
                for (int i=0; i<array_width; i++) {
                    for (int j=0; j<array_height; j++) {
                        [self checkThreadCancel];
                        if (points[i+leftOffset][j+topOffset] == 2) {
                            CLLocationCoordinate2D coordOfLoc = [mapView convertPoint:CGPointMake((double)i, (double)j) toCoordinateFromView:self];
                            [pointsToFill addObject:[PixelLocation pixelLocationWithLatitude:coordOfLoc.latitude andLongitude:coordOfLoc.longitude]];
                            points_that_are_in_area += 1;
                            CLLocationCoordinate2D test1 = [mapView convertPoint:CGPointMake(0.0, (double)j) toCoordinateFromView:self];
                            CLLocationCoordinate2D test2 = [mapView convertPoint:CGPointMake(1.0, (double)j) toCoordinateFromView:self];
                            double distOfPixelForLat = calculateDistance(test1.latitude, test1.longitude, test2.latitude, test2.longitude);
                            double deltaArea = distOfPixelForLat * distOfPixelForLat;
                            totalArea += deltaArea;
                        } 
                    }
                }

                if (![findAreaThread isCancelled]) {
                    [self performSelectorOnMainThread:@selector(areaCalculated:) withObject:[NSNumber numberWithDouble:totalArea] waitUntilDone:FALSE];
                    sum = totalArea;
                }
            } else {
                if (![findAreaThread isCancelled]) {
                    [self performSelectorOnMainThread:@selector(areaCalculated:) withObject:[NSNumber numberWithDouble:-1.0] waitUntilDone:FALSE];
                }
            }
            /* Unload the array of points */
            for (int i=0; i<array_width; i++) {
                free(points[i]);
            }
            free(points);
        }
        
        //NSLog(@"Area Find Mode = %ld", (long)areaFindMode);
        if (areaFindMode == 0) {
            sum = 0.5*fabs(sum);
            CLLocationCoordinate2D pt1 = [mapView convertPoint:CGPointMake(50.0, 50.0) toCoordinateFromView:self];
            CLLocationCoordinate2D pt2 = [mapView convertPoint:CGPointMake(51.0, 50.0) toCoordinateFromView:self];
            double pixelDistance = calculateDistance(pt1.latitude, pt1.longitude, pt2.latitude, pt2.longitude);
            //Multiply pixel area by real area of each square pixel - possibility for error here
            sum = sum * pixelDistance * pixelDistance;
        } else if (areaFindMode == 1) {
            sum = 0.5*fabs(sum);
        }
        
        if (areaFindMode == 0 || areaFindMode == 1) {
            pointsOfPolygon = NSMakeRange(fi, fn-fi);
            CLLocationCoordinate2D *regionCoords = malloc(sizeof(CLLocationCoordinate2D)*((fn-fi)+1));
            NSInteger ri = 0;
            regionCoords[0] = LatLonOfIntersection;
            ri = 1;
            for (int i=fi; i<fn; i++) {
                PixelLocation *temp = [allPointsOnPath objectAtIndex:i];
                regionCoords[ri] = [mapView convertPoint:CGPointMake(temp.x, temp.y) toCoordinateFromView:self];
                ri += 1;
            }
            //regionCoords[ri] = LatLonOfIntersection;
            if (innerPolygon != nil) {
                innerPolygon = nil;
            }
            innerPolygon = [MKPolygon polygonWithCoordinates:regionCoords count:((fn-fi)+1)];
            
        }
        
        [self performSelectorOnMainThread:@selector(areaCalculated:) withObject:[NSNumber numberWithDouble:sum] waitUntilDone:TRUE];
        
    } else {        
        [self performSelectorOnMainThread:@selector(areaCalculated:) withObject:[NSNumber numberWithDouble:-1] waitUntilDone:FALSE];
    }
    
    return;
}

- (void)checkThreadCancel {
    // At some checkpoint
    if([[NSThread currentThread] isCancelled]) {
        if (pointsToFill != nil) {
            [pointsToFill removeAllObjects];
            pointsToFill = nil;
        }
        area = 0;
        [NSThread exit];
    }
}

- (NSInteger)undo:(NSInteger)undo_count {
	
	NSInteger i= 0;
	while ((i<undo_count || ![[drawing_path lastObject] costsUndo]) && [drawing_path count]>0) {
        PixelLocation *p = [drawing_path lastObject];
        if (p.costsUndo) {
            if ([p MapViewPin]!=nil) {
                MKPointAnnotation *pt = [p MapViewPin];
                [mapView removeAnnotation:pt];
            }
            [drawing_path removeLastObject];
            i= i+1;
        } else {
            [drawing_path removeLastObject];
        }
	}
    [self calculateDistance];
	[self setNeedsDisplay];
    return [drawing_path count];
}

/* This method is called when there is an offset and the user has tapped the canvas
 indicating that they want to start drawing the path, but the path has not yet been drawn. */
- (void)configureCanvasForDrawing {
    [stateManager setCanvasStatus:1];
    [self disableTutorialAnimations];
	
	NSInteger y_value= 36;
	if (y_offset > 0) {
		y_value= self.frame.size.height - 50;
	}
	
	button_continue= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UILabel *buttonLabel = [button_continue titleLabel];
    [buttonLabel setNumberOfLines:0];
    [buttonLabel setLineBreakMode:UILineBreakModeWordWrap];
    [buttonLabel setTextAlignment:UITextAlignmentCenter];
	[button_continue setFrame:CGRectMake(MAP_MARGIN, y_value, self.frame.size.width - (MAP_MARGIN * 2), 50)];
	[button_continue setAlpha:0.750f];
    [button_continue setBackgroundColor:[UIColor whiteColor]];
    //Move cursor to start point...
	[button_continue setTitle:NSLocalizedString(@"Start drawing the path on the map", @"...") forState:UIControlStateNormal];
	[button_continue addTarget:self action:@selector(mapRegionContinue) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button_continue];
}

/* This method is called whenever a button needs to appear that prompts the user
 to continue drawing a path on the map, either if the user releases a tap or if
 the map region has changed, hence the name of the method: mapRegionChanged. */
- (void)mapRegionChanged {
    
    NSInteger seenContinuePathInformationBefore = [user_defaults integerForKey:@"SeenContinuePathBefore"];
    if (seenContinuePathInformationBefore != 5) {
        drawPathAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SeenContinuePathBeforeTitle", @"") message:NSLocalizedString(@"SeenContinuePathBeforeMessage", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:NSLocalizedString(@"DontShowSCPBTAgain", @""), nil];
        //[drawPathAlertView show];
    }
	
    [self setNeedsDisplay];
    [stateManager setCanvasStatus:1];
    if (button_continue == nil) {
        button_continue= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button_continue setBackgroundColor:[UIColor whiteColor]];
        [button_continue setFrame:CGRectMake(MAP_MARGIN, MAP_MARGIN + HEIGHT_OF_DISTANCE_TEXT, self.frame.size.width - (2 * MAP_MARGIN), 100)];
        [button_continue setAlpha:0.750f];
        [[button_continue titleLabel] setLineBreakMode:UILineBreakModeWordWrap];
        [[button_continue titleLabel] setTextAlignment:UITextAlignmentCenter];
        [[button_continue titleLabel] setFont:[UIFont fontWithName:@"Helvetica" size:32.0f]];
        [button_continue setTitle:NSLocalizedString(@"Continue drawing the path on the map", @"...") forState:UIControlStateNormal];
        [button_continue addTarget:self action:@selector(mapRegionContinue) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button_continue];
    }
}

- (void)mapRegionContinue {
	
    [button_continue removeFromSuperview];
    button_continue = nil;
    
    CGPoint pixel_location= cursor_pixel;
    pixel_location.y= pixel_location.y + y_offset;
    
	if ([stateManager getCanvasStatus]==1) {
        [stateManager setCanvasStatus:2];
		CLLocationCoordinate2D location= [mapView convertPoint:pixel_location toCoordinateFromView:self];
		first_pixel= pixel_location;
        [self addCoordinateToPath:location withGC:TRUE];
        return;
	}
	
	if ([stateManager canvasIsEditingPath]) {
		CLLocationCoordinate2D location= [mapView convertPoint:first_pixel toCoordinateFromView:self];
		[self addCoordinateToPath:location withGC:TRUE];
        return;
	}
}

- (void)calculateOverlay {
    
    minLat = 100.0;
    maxLat = -100.0;
    minLon = 200.0;
    maxLon = -200.0;
    
    NSEnumerator *pathElementEnumerator = [drawing_path objectEnumerator];
    PixelLocation *element;
    
    while (element = [pathElementEnumerator nextObject]) {
        double lat = [element latitude];
        double lon = [element longitude];
        if (lat > maxLat) {
            maxLat = lat;
        }
        if (lat < minLat) {
            minLat = lat;
        }
        if (lon > maxLon) {
            maxLon = lon;
        }
        if (lon < minLon) {
            minLon = lon;
        }
    }
        
    MKMapPoint map_point_tl = MKMapPointForCoordinate(CLLocationCoordinate2DMake(maxLat, minLon));
    double mp_x_tl = map_point_tl.x;
    double mp_y_tl = map_point_tl.y;
    MKMapPoint map_point_br = MKMapPointForCoordinate(CLLocationCoordinate2DMake(minLat, maxLon));
    double mp_x_br = map_point_br.x;
    double mp_y_br = map_point_br.y;
    MKMapSize map_rect_size = MKMapSizeMake(mp_x_br - mp_x_tl, fabs(mp_y_tl - mp_y_br));
    MKMapRect map_rect = MKMapRectMake(mp_x_tl, mp_y_tl, map_rect_size.width, map_rect_size.height);
    boundingMapRect = map_rect;
    
    coordinate = CLLocationCoordinate2DMake((minLat + maxLat) / 2.0, (minLon + maxLon) / 2.0);
}

- (void)topLabelActivated {
    
    NSString *msg = [NSString stringWithFormat:@"%@\n\n%@", NSLocalizedString(@"CopyToPasteboardMessage", @""), lastDrawnTopBarString];
    copyToPasteboardAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CopyToPasteboardTitle", @"") message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"") otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    [copyToPasteboardAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == copyToPasteboardAlert) {
        if (buttonIndex == 1) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:lastDrawnTopBarString];
        }
    }
    
    if (alertView == drawPathAlertView) {
        if (buttonIndex == 1) {
            [user_defaults setInteger:5 forKey:@"SeenContinuePathBefore"];
            [user_defaults synchronize];
        }
    }
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    
    return TRUE;
}

- (void)aboutToBeRemoved {
    
    NSArray *overlaysArray = [mapView overlays];
    for (int i=0; i<[overlaysArray count]; i++) {
        id<MKOverlay> o = [overlaysArray objectAtIndex:i];
        [mapView removeOverlay:o];
    }
    [findAreaThread cancel];
    if (timerForDrawEnabledAnimator != nil) {
        [timerForDrawEnabledAnimator invalidate];
        timerForDrawEnabledAnimator = nil;
    }
}

- (void)drawEnabledIconAnimator {
    
    void (^_animations)(void) = ^(void) {
        
        if ([drawEnabledIcon alpha] < 0.45f) {
            [drawEnabledIcon setAlpha:0.45f];
            [drawEnabledLabel setBackgroundColor:colorTransparRed];
        } else {
            [drawEnabledIcon setAlpha:0.25f];
            [drawEnabledLabel setBackgroundColor:colorTranspar];
        }
    };
    [UIView animateWithDuration:0.50f animations:_animations];
}

- (void)disableTutorialAnimations {
    
    [drawEnabledIcon setHidden:TRUE];
    [drawEnabledLabel setHidden:TRUE];
    [moveMapTutorialView setHidden:TRUE];
    [drawTutorialBackView setHidden:TRUE];
    [timerForDrawEnabledAnimator invalidate];
    timerForDrawEnabledAnimator = nil;
}

- (PixelLocation *)addPointToPathAtViewPoint:(CGPoint)point {
    
    [stateManager setCanvasStatus:2];
    CLLocationCoordinate2D coord = [mapView convertPoint:point toCoordinateFromView:self];
    return [self addCoordinateToPath:coord withGC:TRUE];
}

- (PixelLocation *)addCoordinateToPath:(CLLocationCoordinate2D)_coord withGC:(BOOL)gc {
    if (drawing_path == nil) {
        drawing_path= [NSMutableArray arrayWithCapacity:100];
        [drawing_path retain];
        [self disableTutorialAnimations];
    }
    
    CLLocationCoordinate2D coord = _coord;
    coord.latitude = [CMDGreatCircle normalizeLatitude:coord.latitude];
    PixelLocation *loc = [PixelLocation pixelLocationWithLatitude:coord.latitude andLongitude:coord.longitude];
    MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
    loc.x = mapPoint.x;
    loc.y = mapPoint.y;
    if (![CMDGreatCircle isValidCoordinate:loc.latitude andLon:loc.longitude]) {
        //Do NOT add this coordinate if it is not a valid coordinate
        return nil;
    }
    if ([drawing_path count]>0) {
        PixelLocation *head = [drawing_path objectAtIndex:[drawing_path count]-1];
        CLLocationCoordinate2D headCoord = CLLocationCoordinate2DMake(head.latitude, head.longitude);
        double distanceOfNextPoint = [CMDGreatCircle metersBetween:headCoord and:coord];
        if (distanceOfNextPoint > METERS_FOR_GREAT_CIRCLE && gc) {
            //Distance is long - use a great circle instead of a straight line to draw the path
            for (int i=1; i<100; i++) {
                CLLocationCoordinate2D intermediatePoint = [CMDGreatCircle intermediatePointBetween:headCoord and:coord withFraction:(double)i/100];
                PixelLocation *p = [PixelLocation pixelLocationWithLatitude:intermediatePoint.latitude andLongitude:intermediatePoint.longitude];
                p.costsUndo = FALSE;
                [drawing_path addObject:p];
            }
        }
    }
    [drawing_path addObject:loc];
    //Check to see if newest addition to drawing path requires an area calculation
    //TODO: WARNING: THIS IS O(n)
    if ([self pathCheckIntersectionAtIndex:([drawing_path count]-1)]) {
        demandsAreaCalculation = TRUE;
    }
    
    if (!isBeingInteractedWith) {
        [self mapRegionChanged];
        if (mode == 1) {
            [self calculateAreaThread];
        }
    }
    [self calculateDistance];
    [self setNeedsDisplay];
    
    return loc;
}

- (double)distanceForRestOfPath:(CLLocationCoordinate2D)coord {
    
    double minDist = 1000000000000;
    NSInteger minI = 0;
    for (NSInteger i=0; i<[drawing_path count]; i++) {
        PixelLocation *crd = [drawing_path objectAtIndex:i];
        double dist = calculateDistance(coord.latitude, coord.longitude, crd.latitude, crd.longitude);
        if (dist < minDist) {
            minDist = dist;
            minI = i;
        }
    }
    
    double d = 0;
    if (mode == 0) {
        //Recalculate the approximate distance of the path drawn by the pixels
        for (NSInteger i=(minI+1); i<[drawing_path count]; i+=1) {
            PixelLocation *pt1= [drawing_path objectAtIndex:(i-1)];
            PixelLocation *pt2= [drawing_path objectAtIndex:i];
            
            d = d + calculateDistance(pt1.latitude, pt1.longitude, pt2.latitude, pt2.longitude);
        }
    }
    return d;
}

- (double)distanceToLastPoint:(CLLocationCoordinate2D)coord {
    
    PixelLocation *crd = [drawing_path lastObject];
    return calculateDistance(coord.latitude, coord.longitude, crd.latitude, crd.longitude);
}

- (NSString *)stringForDistanceOrArea:(double)distance_delta {
    
    return [self stringForDistanceOrAreaPrivate:distance andArea:area andMode:mode andDelta:distance_delta];
}

- (NSString *)stringForDistanceOrAreaPrivate:(double)d andArea:(double)a andMode:(NSInteger)m andDelta:(double)distance_delta; {
    
    double multiply_factor;
    NSString *units_string;
    NSString *units_string2;
    [user_defaults synchronize];
    NSInteger metric= [user_defaults integerForKey:@"metric"];
    
    switch (metric) {
        case 0:
            multiply_factor= MILES_PER_METER;
            if (language==nil) {
                units_string= @"miles";
            }
            else {
                if ([language compare:@"fr_FR"]==NSOrderedSame) {
                    units_string= @"milles";
                }
            }
            break;
        case 1:
            multiply_factor= 0.001f;
            if (language==nil) {
                units_string= @"kilometers";
            }
            else {
                if ([language compare:@"fr_FR"]==NSOrderedSame) {
                    units_string= @"kilometres";
                }
            }
            break;
        case 2:
            multiply_factor = 1.09361;
            units_string = NSLocalizedString(@"Yards", @"");
            break;
        case 3:
            //This mode is not available to users, but presents distance in meters
            multiply_factor= 1.000f;
            if (language==nil) {
                units_string= @"meters";
            }
            else {
                if ([language compare:@"fr_FR"]==NSOrderedSame) {
                    units_string= @"metres";
                }
            }
            break;
        default:
            multiply_factor= MILES_PER_METER;
            if (language==nil) {
                units_string= @"miles";
            }
            else {
                if ([language compare:@"fr_FR"]==NSOrderedSame) {
                    units_string= @"miles";
                }
            }
            break;
    }
    
    NSString *draw_text_string;
    double distance_to_use = d + distance_delta;
    
    //Round numbers depending on how large they are!
    NSString *numStringA = [nf stringFromNumber:[NSNumber numberWithDouble:distance_to_use*multiply_factor]];
    NSString *numStringB = numStringA;
    
    if (language==nil) {
        draw_text_string= [NSString stringWithFormat:@"%@ %@", numStringB, units_string];
    }
    else {
        if ([language compare:@"fr_FR"]==NSOrderedSame) {
            draw_text_string= [NSString stringWithFormat:@"%@ %@", numStringB, units_string];
        }
    }
    
    double converted_area = -1.0;
    double converted_area2 = -1.0;
    units_string = @"";
    units_string2 = @"";
    
    if (metric == 0 || metric == 2) {
        converted_area = a * 0.000247105381;             //Acres
        converted_area2 = a * 3.86102159 * 0.0000001;    //Square miles
        units_string = NSLocalizedString(@"Acres", @"");
        units_string2 = NSLocalizedString(@"SquareMiles", @"");
    }
    if (metric == 1) {
        converted_area = a * 0.000001;                   //Square kilometers
        converted_area2 = a * 0.0001;                    //Hectares
        units_string = NSLocalizedString(@"Square Kilometers", @"");
        units_string2 = NSLocalizedString(@"Hectares", @"");
    }
    NSString *areaString;
    if (area > 0) {
        areaString = [NSString stringWithFormat:@"%@ %@ %@; %@ %@", NSLocalizedString(@"Area", @""), [nf stringFromNumber:[NSNumber numberWithDouble:converted_area]], units_string, [nf stringFromNumber:[NSNumber numberWithDouble:converted_area2]], units_string2];
    } else {
        areaString = NSLocalizedString(@"AreaNotCalc", @"");
    }
    
    if (m == 0) {
        return draw_text_string;
    } else {
        return areaString;
    }
}

- (void)addNewMeasurement {
    if (measurementsCount == 0) {
        NSLog(@"Add first measurement before adding new ones");
    }
    if (mode == 0 || mode == 1) {
        CLLocationCoordinate2D *coordArray = malloc(sizeof(CLLocationCoordinate2D) * [drawing_path count]);
        for (int i=0; i<[drawing_path count]; i++) {
            PixelLocation *p = [drawing_path objectAtIndex:i];
            coordArray[i] = CLLocationCoordinate2DMake(p.latitude, p.longitude);
        }
        MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordArray count:[drawing_path count]];
        prev_meas_distance = distance;
        [drawing_path removeAllObjects];
        distance = 0;
        [mapView addOverlay:polyLine];
    }
    if (mode == 1) {
        prev_meas_area = area;
        area = 0;
        frozen = FALSE;
        [drawing_path removeAllObjects];
    }
}

- (void)dealloc {
	[drawing_path removeAllObjects];
	[drawing_path release];
    [self disableTutorialAnimations];
    [drawEnabledIcon removeFromSuperview];
    [drawEnabledLabel removeFromSuperview];
    [mapMoveTutorialLabel removeFromSuperview];
    [moveMapTutorialView removeFromSuperview];
    [super dealloc];
}


@end
