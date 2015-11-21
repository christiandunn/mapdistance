//
//  MapDistancePersistentOverlayView.m
//  MapDistance
//
//  Created by Christian Dunn on 12/28/12.
//
//

#import "MapDistancePersistentOverlayView.h"

double pow10roundUp(double number, double calibration) {
    
    return ceil(number/calibration)*calibration;
}

@implementation MapDistancePersistentOverlayView

@synthesize center;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = FALSE;
        center = CGPointMake(frame.size.width/2, frame.size.height/2);
        
        latlonLabel = [[UILabel alloc] initWithFrame:CGRectMake(center.x - 50, center.y - 20, 100, 20)];
        [latlonLabel setTextColor:[UIColor colorWithRed:0.0f green:0.2f blue:0.0f alpha:0.5f]];
        [latlonLabel setFont:[UIFont fontWithName:@"Helvetica" size:8.0f]];
        [latlonLabel setTextAlignment:NSTextAlignmentCenter];
        [latlonLabel setAdjustsFontSizeToFitWidth:TRUE];
        [latlonLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:latlonLabel];
    }
    return self;
}

- (void)setMapView:(MKMapView *)mapView {
    
    map = mapView;
    center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    //Draw the red circle in center of map
    CGContextSetStrokeColorWithColor(c, [[UIColor redColor] CGColor]);
    CGContextStrokeEllipseInRect(c, CGRectMake(center.x - 2, center.y - 2, 4, 4));
    
    //Don't draw anything else if this view is "effectively hidden"
    if (effectivelyHidden) {
        return;
    }
    
    //Need to make it so these lines draw even if the map is tilted
    //Southmost
    double minLat = 90.0;
    CGPoint southernMostPoint = CGPointMake(0, 0);
    if ([map convertPoint:CGPointMake(0, 0) toCoordinateFromView:self].latitude < minLat) {
        minLat = [map convertPoint:CGPointMake(0, 0) toCoordinateFromView:self].latitude;
    }
    if ([map convertPoint:CGPointMake(self.frame.size.width, 0) toCoordinateFromView:self].latitude < minLat) {
        minLat = [map convertPoint:CGPointMake(self.frame.size.width, 0) toCoordinateFromView:self].latitude;
        southernMostPoint = CGPointMake(self.frame.size.width, 0);
    }
    if ([map convertPoint:CGPointMake(self.frame.size.width, self.frame.size.height) toCoordinateFromView:self].latitude < minLat) {
        minLat = [map convertPoint:CGPointMake(self.frame.size.width, self.frame.size.height) toCoordinateFromView:self].latitude;
        southernMostPoint = CGPointMake(self.frame.size.width, self.frame.size.height);
    }
    if ([map convertPoint:CGPointMake(0, self.frame.size.height) toCoordinateFromView:self].latitude < minLat) {
        minLat = [map convertPoint:CGPointMake(0, self.frame.size.height) toCoordinateFromView:self].latitude;
        southernMostPoint = CGPointMake(0, self.frame.size.height);
    }
    //Westmost
    double minLon = 1000.0;
    CGPoint westMostPoint = CGPointMake(0, 0);
    if ([map convertPoint:CGPointMake(0, 0) toCoordinateFromView:self].longitude < minLon) {
        minLon = [map convertPoint:CGPointMake(0, 0) toCoordinateFromView:self].longitude;
    }
    if ([map convertPoint:CGPointMake(self.frame.size.width, 0) toCoordinateFromView:self].longitude < minLon) {
        minLon = [map convertPoint:CGPointMake(self.frame.size.width, 0) toCoordinateFromView:self].longitude;
        westMostPoint = CGPointMake(self.frame.size.width, 0);
    }
    if ([map convertPoint:CGPointMake(self.frame.size.width, self.frame.size.height) toCoordinateFromView:self].longitude < minLon) {
        minLon = [map convertPoint:CGPointMake(self.frame.size.width, self.frame.size.height) toCoordinateFromView:self].longitude;
        westMostPoint = CGPointMake(self.frame.size.width, self.frame.size.height);
    }
    if ([map convertPoint:CGPointMake(0, self.frame.size.height) toCoordinateFromView:self].longitude < minLon) {
        minLon = [map convertPoint:CGPointMake(0, self.frame.size.height) toCoordinateFromView:self].longitude;
        westMostPoint = CGPointMake(0, self.frame.size.height);
    }
    //Northmost
    CGPoint northMost = CGPointMake(ABS(southernMostPoint.x - self.frame.size.width), ABS(southernMostPoint.y - self.frame.size.height));
    //Eastmost
    CGPoint eastMost = CGPointMake(ABS(westMostPoint.x - self.frame.size.width), ABS(westMostPoint.y - self.frame.size.height));
    
    double top = [map convertPoint:northMost toCoordinateFromView:self].latitude;
    double bottom = [map convertPoint:southernMostPoint toCoordinateFromView:self].latitude;
    double left = [map convertPoint:westMostPoint toCoordinateFromView:self].longitude;
    double right = [map convertPoint:eastMost toCoordinateFromView:self].longitude;
    
    double latdelta = top - bottom;
    double londelta = [CMDGreatCircle differenceInLongitude:left and:right];
    double latcalibration = MIN(pow(10,floor(log10(latdelta))),10);
    double loncalibration = MIN(pow(10,floor(log10(londelta))),10);
    
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.20f] CGColor]);
    NSInteger i;
    double lat = [CMDGreatCircle normalizeLatitude:pow10roundUp(bottom, latcalibration)];
    for (i = 0; i <= ceil(2.0*latdelta/latcalibration); i++) {
        CLLocationCoordinate2D c1 = CLLocationCoordinate2DMake(lat, left);
        CLLocationCoordinate2D c2 = CLLocationCoordinate2DMake(lat, right);
        CGPoint p1 = [map convertCoordinate:c1 toPointToView:self];
        CGPoint p2 = [map convertCoordinate:c2 toPointToView:self];
        CGContextSetLineWidth(c, 1.0);
        if (ABS(lat)<0.000001) {
            CGContextSetLineWidth(c, 3.0);
        }
        CGContextMoveToPoint(c, p1.x, p1.y);
        CGContextAddLineToPoint(c, p2.x, p2.y);
        //NSLog(@"%f,%f   %f,%f", p1.x,p1.y,p2.x,p2.y);
        CGContextStrokePath(c);
        lat = [CMDGreatCircle normalizeLatitude:(lat + latcalibration)];
    }
    double lon = [CMDGreatCircle normalizeLongitude:pow10roundUp(left, loncalibration)];
    for (i = 0; i <= ceil(1.5*londelta/loncalibration); i++) {
        CLLocationCoordinate2D c1 = CLLocationCoordinate2DMake(bottom, lon);
        CLLocationCoordinate2D c2 = CLLocationCoordinate2DMake(top, lon);
        CGPoint p1 = [map convertCoordinate:c1 toPointToView:self];
        CGPoint p2 = [map convertCoordinate:c2 toPointToView:self];
        CGContextSetLineWidth(c, 1.0);
        if ((180-ABS(lon)<0.01 || ABS(lon)<0.01) && londelta > 0.2) {
            CGContextSetLineWidth(c, 3.0);
        }
        CGContextMoveToPoint(c, p1.x, p1.y);
        CGContextAddLineToPoint(c, p2.x, p2.y);
        CGContextStrokePath(c);
        lon = [CMDGreatCircle normalizeLongitude:(lon + loncalibration)];
    }
    
    //Draw the arctic circle
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.20f] CGColor]);
    CLLocationCoordinate2D c1 = CLLocationCoordinate2DMake(90.0 - EARTH_AXIAL_TILT_DEGREES, left);
    CLLocationCoordinate2D c2 = CLLocationCoordinate2DMake(90.0 - EARTH_AXIAL_TILT_DEGREES, right);
    CGPoint p1 = [map convertCoordinate:c1 toPointToView:self];
    CGPoint p2 = [map convertCoordinate:c2 toPointToView:self];
    CGContextSetLineWidth(c, 1.0);
    CGContextSetLineWidth(c, 1.0f);
    CGContextMoveToPoint(c, p1.x, p1.y);
    CGContextAddLineToPoint(c, p2.x, p2.y);
    CGContextStrokePath(c);
    //Draw the ant-arctic circle
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.20f] CGColor]);
    c1 = CLLocationCoordinate2DMake(-90.0 + EARTH_AXIAL_TILT_DEGREES, left);
    c2 = CLLocationCoordinate2DMake(-90.0 + EARTH_AXIAL_TILT_DEGREES, right);
    p1 = [map convertCoordinate:c1 toPointToView:self];
    p2 = [map convertCoordinate:c2 toPointToView:self];
    CGContextSetLineWidth(c, 1.0);
    CGContextSetLineWidth(c, 1.0f);
    CGContextMoveToPoint(c, p1.x, p1.y);
    CGContextAddLineToPoint(c, p2.x, p2.y);
    CGContextStrokePath(c);
    //Draw the tropics
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:0.20f] CGColor]);
    c1 = CLLocationCoordinate2DMake(EARTH_AXIAL_TILT_DEGREES, left);
    c2 = CLLocationCoordinate2DMake(EARTH_AXIAL_TILT_DEGREES, right);
    p1 = [map convertCoordinate:c1 toPointToView:self];
    p2 = [map convertCoordinate:c2 toPointToView:self];
    CGContextSetLineWidth(c, 1.0);
    CGContextSetLineWidth(c, 1.0f);
    CGContextMoveToPoint(c, p1.x, p1.y);
    CGContextAddLineToPoint(c, p2.x, p2.y);
    CGContextStrokePath(c);
    //Draw the tropics
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:0.20f] CGColor]);
    c1 = CLLocationCoordinate2DMake(-EARTH_AXIAL_TILT_DEGREES, left);
    c2 = CLLocationCoordinate2DMake(-EARTH_AXIAL_TILT_DEGREES, right);
    p1 = [map convertCoordinate:c1 toPointToView:self];
    p2 = [map convertCoordinate:c2 toPointToView:self];
    CGContextSetLineWidth(c, 1.0);
    CGContextSetLineWidth(c, 1.0f);
    CGContextMoveToPoint(c, p1.x, p1.y);
    CGContextAddLineToPoint(c, p2.x, p2.y);
    CGContextStrokePath(c);
}

- (void)setNeedsDisplay {
    
    center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    CLLocationCoordinate2D coord = [map convertPoint:center toCoordinateFromView:self];
    NSString *latlonString = [NSString stringWithFormat:@"%f, %f", coord.latitude, coord.longitude];
    [latlonLabel setFrame:CGRectMake(center.x - 50, center.y - 20, 100, 20)];
    [latlonLabel setText:latlonString];
    
    [super setNeedsDisplay];
}

- (void)setEffectivelyHidden:(BOOL)tf {
    effectivelyHidden = tf;
    [latlonLabel setHidden:effectivelyHidden];
    [self setNeedsDisplay];
}

@end
