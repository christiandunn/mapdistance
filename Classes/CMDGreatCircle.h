//
//  CMDGreatCircle.h
//  MapDistance
//
//  Created by Christian Dunn on 7/23/14.
//
//  "We cannot fight for love, as men may do; we shou'd be woo'd, and were not made to woo"
//

#import <Foundation/Foundation.h>

@interface CMDGreatCircle : NSObject {
    ;
}

+(double)greatCircleDistanceBetween:(CLLocationCoordinate2D)a and:(CLLocationCoordinate2D)b;
+(double)metersBetween:(CLLocationCoordinate2D)a and:(CLLocationCoordinate2D)b;
+(CLLocationCoordinate2D)intermediatePointBetween:(CLLocationCoordinate2D)a and:(CLLocationCoordinate2D)b withFraction:(double)f;
+(double)differenceInLongitude:(double)lon1 and:(double)lon2;

+(double)normalizeLatitude:(double)lat;
+(double)normalizeLongitude:(double)lon;

+(BOOL)isValidCoordinate:(double)lat andLon:(double)lon;

@end
