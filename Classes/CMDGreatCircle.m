//
//  CMDGreatCircle.m
//  MapDistance
//
//  Created by Christian Dunn on 7/23/14.
//
//

#import "CMDGreatCircle.h"

@implementation CMDGreatCircle

+(double)greatCircleDistanceBetween:(CLLocationCoordinate2D)a and:(CLLocationCoordinate2D)b {
    //Takes latitude and longitude in DEGREES, not RADIANS
    //Source: http://stackoverflow.com/questions/1868115/calculating-shortest-path-between-2-points-on-a-flat-map-of-the-earth
    
    double lat1 = a.latitude*M_PI/180.0;
    double lon1 = a.longitude*M_PI/180.0;
    double lat2 = b.latitude*M_PI/180.0;
    double lon2 = b.longitude*M_PI/180.0;
    //Distance d is in radians, where 2*pi radians is a full circle
    double d=2*asin(sqrt(pow(sin((lat1-lat2)/2),2)+cos(lat1)*cos(lat2)*pow(sin((lon1-lon2)/2),2)));
    return d;
}

+(double)metersBetween:(CLLocationCoordinate2D)a and:(CLLocationCoordinate2D)b {
    //Takes latitude and longitude in DEGREES, not RADIANS
    return [CMDGreatCircle greatCircleDistanceBetween:a and:b]*RADIUS_OF_EARTH;
}

+(CLLocationCoordinate2D)intermediatePointBetween:(CLLocationCoordinate2D)a and:(CLLocationCoordinate2D)b withFraction:(double)f {
    //Takes latitude and longitude in DEGREES, not RADIANS
    //Source: http://stackoverflow.com/questions/1868115/calculating-shortest-path-between-2-points-on-a-flat-map-of-the-earth
    
    double lat1 = a.latitude;
    double lon1 = a.longitude;
    double lat2 = b.latitude;
    double lon2 = b.longitude;
    double d = [CMDGreatCircle greatCircleDistanceBetween:a and:b];
    lat1 = lat1*M_PI/180.0;
    lon1 = lon1*M_PI/180.0;
    lat2 = lat2*M_PI/180.0;
    lon2 = lon2*M_PI/180.0;
    
    double A=sin((1-f)*d)/sin(d);
    double B=sin(f*d)/sin(d);
    double x = A*cos(lat1)*cos(lon1) +  B*cos(lat2)*cos(lon2);
    double y = A*cos(lat1)*sin(lon1) +  B*cos(lat2)*sin(lon2);
    double z = A*sin(lat1)           +  B*sin(lat2);
    double lat=atan2(z,sqrt(pow(x, 2.0)+pow(y, 2.0)));
    double lon=atan2(y,x);
    
    return CLLocationCoordinate2DMake((CLLocationDegrees)lat*180.0/M_PI, (CLLocationDegrees)lon*180.0/M_PI);
}

+(double)differenceInLongitude:(double)lon1 and:(double)lon2 {
    double d = MIN(ABS(lon2 - lon1), 360.0 + lon2 - lon1);
    return d;
}

+(double)normalizeLatitude:(double)lat {
    if (lat >= 90.0) {
        return 89.99;
    }
    if (lat <= -90.0) {
        return -89.99;
    }
    return lat;
}

+(double)normalizeLongitude:(double)lon {
    if (ABS(lon-180.0)<0.01 || ABS(lon+180.0)<0.01) {
        return 179.99;
    }
    if (lon > 180.0) {
        return lon - 360.0;
    }
    if (lon < -180.0) {
        return lon + 360.0;
    }
    return lon;
}

+(BOOL)isValidCoordinate:(double)lat andLon:(double)lon {
    if (lat > 90.00 || lat < -90.0) {
        return FALSE;
    }
    if (lon > 180.0 || lon < -180.0) {
        return FALSE;
    }
    return TRUE;
}

@end
