//
//  MapScaleView.m
//  MapDistance
//
//  Created by Christian Dunn on 8/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapScaleView.h"


@implementation MapScaleView

@synthesize theMapView;

void centerTextInContextAtOrigin2(
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
	CGFloat color[4] = {0.0f, 0.0f, 0.0f, 1.0f};
	CGContextSetFillColor(cgContext, color);
	CGContextShowTextAtPoint(cgContext,
							 x, y+(textSize/2), text, strlen(text));
	
	CGContextRestoreGState(cgContext);
}


- (void)initializeThis {
    
    /* Make it so that touches pass through the view */
    [self setUserInteractionEnabled:FALSE];
    /* Other initialization steps */
    self.clearsContextBeforeDrawing = TRUE;
    self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    
    nf = [[NSNumberFormatter alloc] init];
    [nf setUsesGroupingSeparator:TRUE];
    [nf setUsesSignificantDigits:TRUE];
    [nf setMaximumSignificantDigits:1];
    [nf setMinimumSignificantDigits:0];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CLLocationCoordinate2D point1 = [theMapView convertPoint:CGPointMake(self.frame.origin.x, self.frame.origin.y) toCoordinateFromView:theMapView];
    CLLocationCoordinate2D point2 = [theMapView convertPoint:CGPointMake(self.frame.origin.x + 200, self.frame.origin.y) toCoordinateFromView:theMapView];
    CLLocation *pt1 =  [[CLLocation alloc] initWithLatitude:point1.latitude longitude:point1.longitude];
    CLLocation *pt2 = [[CLLocation alloc] initWithLatitude:point2.latitude longitude:point2.longitude];
    double distance = [pt1 distanceFromLocation:pt2];
    
    double multiply_factor;
    NSString *units_string;
    NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
    NSInteger metric= [user_defaults integerForKey:@"metric"];
    NSUserDefaults *defaults = user_defaults;
    NSString *language = nil;
    NSArray *languages= [defaults objectForKey:@"AppleLanguages"];
	NSString *currentLanguage= [languages objectAtIndex:0];
	if ([currentLanguage compare:@"fr"]==NSOrderedSame) {
		language= @"fr_FR";
		[language retain];
	}
	else {
		language= nil;
	}
    
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
                units_string= @"km";
            }
            else {
                if ([language compare:@"fr_FR"]==NSOrderedSame) {
                    units_string= @"km";
                }
            }
            break;
        case 2:
            multiply_factor= 1.09361;
            if (language==nil) {
                units_string= @"yds.";
            }
            else {
                if ([language compare:@"fr_FR"]==NSOrderedSame) {
                    units_string= @"yds.";
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
                    units_string= @"milles";
                }
            }
            break;
    }
    
    double maxOutScaleBarNumber = distance*multiply_factor;
    double powerOfTen = floor(log10(maxOutScaleBarNumber));
    double numberDisplayed = floor(maxOutScaleBarNumber/pow(10,powerOfTen))*pow(10, powerOfTen);
    double ratio = numberDisplayed/maxOutScaleBarNumber;
    
    /* Draw the actual lines */
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.7f] CGColor]);
    CGContextSetLineWidth(c, 1.5f);
    CGContextStrokeRect(c, CGRectMake(10, 8, 200*ratio, 8));
    CGContextMoveToPoint(c, 10 + 200*ratio*0.5, 16);
    CGContextAddLineToPoint(c, 10 + 200*ratio*0.5, 8);
    CGContextStrokePath(c);
    CGContextSetFillColorWithColor(c, [[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.2f] CGColor]);
    CGContextFillRect(c, CGRectMake(10, 8, 200*ratio, 8));
    NSString *numberString = [nf stringFromNumber:[NSNumber numberWithDouble:numberDisplayed]];
    NSString *str = [NSString stringWithFormat:@"%@", numberString];
    //Use units_string if needed
    centerTextInContextAtOrigin2(c, 10 + 200*ratio + 6.5, 10, "Helvetica", 14.0f, [str UTF8String]);
}

@end
