//
//  DrawingCpanelView.m
//  MapDistance
//
//  Created by Christian Dunn on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DrawingCpanelView.h"

@implementation DrawingCpanelView

@synthesize allowDrawSwitch;
@synthesize straightLineSwitch;
@synthesize useAreaSwitch;
@synthesize settingsButtonPressed;
@synthesize isVisibleInMainView;
@synthesize areaLabel;

@synthesize canvas;
@synthesize map_view;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        defs = [NSUserDefaults standardUserDefaults];
        [defs synchronize];
        
        mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [mainScrollView setContentSize:CGSizeMake(frame.size.width, 97)];
        [mainScrollView setScrollEnabled:FALSE];
        [self addSubview:mainScrollView];
        
        allowDrawSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10, 5, 140, 20)];
        [allowDrawSwitch setOn:TRUE];
        [allowDrawSwitch setEnabled:FALSE];
        [allowDrawSwitch setHidden:TRUE];
        [allowDrawSwitch addTarget:self action:@selector(allowDrawToggle) forControlEvents:UIControlEventValueChanged];
        [mainScrollView addSubview:allowDrawSwitch];
        allowDrawLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 8, 190, 20)];
        [allowDrawLabel setText:NSLocalizedString(@"AllowDrawLabel", @"")];
        [allowDrawLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0f]];
        [allowDrawLabel setBackgroundColor:COLOR_TRANSPAR];
        [allowDrawLabel setHidden:TRUE];
        [mainScrollView addSubview:allowDrawLabel];
        
        useAreaSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(25, 5, 140, 32)];
        NSInteger areaDefs = [defs integerForKey:@"UseAreaSwitch"];
        if (areaDefs == 5) {
            [useAreaSwitch setOn:TRUE];
        }
        if (areaDefs == 2) {
            [useAreaSwitch setOn:FALSE];
        }
        [useAreaSwitch setEnabled:TRUE];
        [useAreaSwitch addTarget:self action:@selector(useAreaToggle) forControlEvents:UIControlEventValueChanged];
        [mainScrollView addSubview:useAreaSwitch];
        useAreaLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 5, 190, 32)];
        [useAreaLabel setText:NSLocalizedString(@"UseAreaLabel", @"")];
        [useAreaLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0f]];
        [useAreaLabel setBackgroundColor:COLOR_TRANSPAR];
        [useAreaLabel setAdjustsFontSizeToFitWidth:TRUE];
        [useAreaLabel setTextAlignment:NSTextAlignmentLeft];
        [mainScrollView addSubview:useAreaLabel];
        isVisibleInMainView = FALSE;
        
        addNewMeasurementButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [addNewMeasurementButton setTitle:NSLocalizedString(@"AddNewMeasurementButton", @"") forState:UIControlStateNormal];
        [addNewMeasurementButton addTarget:self action:@selector(addNewMeasurement) forControlEvents:UIControlEventTouchUpInside];
        [addNewMeasurementButton setFrame:CGRectMake(20, 45, 60, 20)];
        [mainScrollView addSubview:addNewMeasurementButton];
        addNewMeasurementLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 42, 190, 20)];
        [addNewMeasurementLabel setText:NSLocalizedString(@"AddNewMeasurementLabel", @"")];
        [addNewMeasurementLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0f]];
        [addNewMeasurementLabel setBackgroundColor:COLOR_TRANSPAR];
        [addNewMeasurementLabel setAdjustsFontSizeToFitWidth:TRUE];
        [addNewMeasurementLabel setTextAlignment:NSTextAlignmentLeft];
        [mainScrollView addSubview:addNewMeasurementLabel];
        
        [self setBackgroundColor:COLOR_SCHEME_1];
        areaLabel = nil;
    }
    return self;
}

- (void)allowDrawToggle {
    
    if (allowDrawSwitch.on) {
        if (map_view!=nil && canvas!=nil) {
            if (polyLine != nil) {
                [map_view removeOverlay:polyLine];
                //Must set this to nil or it will cause an error here next time around
                polyLine = nil;
            }
            [map_view removeOverlay:canvas];
            [map_view removeOverlay:polygon];
            [canvas setUserInteractionEnabled:TRUE];
            [canvas setHidden:FALSE];
            [canvas setNeedsDisplay];
            if (isVisibleInMainView) {
                [settingsButtonPressed invoke];
            }
            if (areaLabel != nil) {
                [areaLabel removeFromSuperview];
                areaLabel = nil;
            }
        }
    } else {
        /* If area was being used, don't allow return to drawing mode */
        /* This part could be removed if the canvas can automatically flip the switch */
        /* This part should definitely be removed if multiple regions can now be drawn. */
        if ([canvas area] > 0) {
            [allowDrawSwitch setEnabled:FALSE];
        }
        /* End "This part" */
        
        /* Make the path canvas an overlay so that the map can be moved */
        NSMutableArray *pointsArray = [canvas drawing_path];
        CLLocationCoordinate2D *coordArray = malloc(sizeof(CLLocationCoordinate2D) * [pointsArray count]);
        for (int i=0; i<[pointsArray count]; i++) {
            PixelLocation *px = [pointsArray objectAtIndex:i];
            coordArray[i] = CLLocationCoordinate2DMake(px.latitude, px.longitude);
        }
        polyLine = [MKPolyline polylineWithCoordinates:coordArray count:[pointsArray count]];
        /*
        if ([canvas area] > 0 && [canvas pointOfIntersection] != nil) {
            //This code prepares to add and does add an MKPolygon for the area represented
            NSInteger firstIndex = -1;
            NSInteger secondIndex = -1;
            
         
            PixelLocation *latlon = [canvas pointOfIntersection];
            firstIndex = 5;
            secondIndex = 5;
            if (firstIndex > -1 && secondIndex > -1) {
                
                NSArray *newArray1 = [pointsArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:canvas.pointsOfPolygon]];
                NSMutableArray *newArray = [NSMutableArray arrayWithArray:newArray1];
                [newArray addObject:latlon];
                [newArray insertObject:latlon atIndex:0];
                CLLocationCoordinate2D *newCoords = malloc(sizeof(CLLocationCoordinate2D) * [newArray count]);
                for (int i=0; i<[newArray count]; i++) {
                    PixelLocation *px = [newArray objectAtIndex:i];
                    newCoords[i] = CLLocationCoordinate2DMake(px.latitude, px.longitude);
                }
                polygon = [MKPolygon polygonWithCoordinates:newCoords count:[newArray count]];
            } else {
                
                polygon = [MKPolygon polygonWithCoordinates:coordArray count:[pointsArray count]];
            }
            [map_view removeOverlay:[canvas innerPolygon]];
            [map_view addOverlay:polygon];
        }
         */
        free(coordArray);
        [canvas calculateOverlay];
        //Add PolyLine to the map - red line for when map move is enabled
        [map_view addOverlay:polyLine];
        //Add Area Polygon to the map
        //[map_view addOverlay:canvas];
        [canvas setUserInteractionEnabled:FALSE];
        [canvas setHidden:TRUE];
        if (isVisibleInMainView) {
            [settingsButtonPressed invoke];
        }
        
        areaLabel = [[LabelWithAction alloc] initWithFrame:CGRectMake(0.0, 0.0, map_view.frame.size.width, HEIGHT_OF_DISTANCE_TEXT)];
        NSMethodSignature *msigClipboard = [[self class] instanceMethodSignatureForSelector:@selector(topLabelActivated)];
        NSInvocation *invClipboard = [NSInvocation invocationWithMethodSignature:msigClipboard];
        [invClipboard setTarget:self];
        [invClipboard setSelector:@selector(topLabelActivated)];
        [areaLabel setLabelTapInvocation:invClipboard];
        [areaLabel setTextColor:COLOR_SCHEME_2];
        areaLabel.layer.borderColor = COLOR_SCHEME_2.CGColor;
        areaLabel.layer.borderWidth = 2.0;
        if ([[canvas lastDrawnTopBarString] length] > 0) {
            [areaLabel setText:[canvas stringForDistanceOrArea:0.0]];
        } else {
            [areaLabel setText:NSLocalizedString(@"CanNowMoveMap", @"")];
        }
        [areaLabel setAdjustsFontSizeToFitWidth:TRUE];
        [areaLabel setUserInteractionEnabled:TRUE];
        [areaLabel setTextAlignment:UITextAlignmentCenter];
        [areaLabel setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
        [map_view addSubview:areaLabel];
        [map_view bringSubviewToFront:areaLabel];
        
        Class thisclass = [self class];
        NSMethodSignature *msig = [thisclass instanceMethodSignatureForSelector:@selector(areaWasCalculated)];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:msig];
        [inv setTarget:self];
        [inv setSelector:@selector(areaWasCalculated)];
        [canvas setAreaCalculatedUpdate:inv];
    }
}

- (void)useAreaToggle {
    
    if (useAreaSwitch.on) {
        [canvas setMode:1];
        [defs setInteger:5 forKey:@"UseAreaSwitch"];
    } else {
        [canvas setMode:0];
        [defs setInteger:2 forKey:@"UseAreaSwitch"];
    }
    [defs synchronize];
    [settingsButtonPressed invoke];
}

- (void)useAreaToggleNoOpen {
    
    if (useAreaSwitch.on) {
        [canvas setMode:1];
        [defs setInteger:5 forKey:@"UseAreaSwitch"];
    } else {
        [canvas setMode:0];
        [defs setInteger:2 forKey:@"UseAreaSwitch"];
    }
    [defs synchronize];
}

- (void)topLabelActivated {
    NSString *msg = [NSString stringWithFormat:@"%@\n\n%@", NSLocalizedString(@"CopyToPasteboardMessage", @""), areaLabel.text];
    copyToPasteboardAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CopyToPasteboardTitle", @"") message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"") otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    [copyToPasteboardAlert show];
}

- (void)areaWasCalculated {
    
    if (areaLabel != nil) {
        [areaLabel setText:[canvas stringForDistanceOrArea:0.0]];
    }
}

- (void)addNewMeasurement {
    if (canvas != nil) {
        [canvas addNewMeasurement];
    }
}

- (void)canvasWasRemoved {
    
    if (areaLabel != nil) {
        [areaLabel removeFromSuperview];
        areaLabel = nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
