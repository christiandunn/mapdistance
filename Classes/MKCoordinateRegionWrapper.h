//
//  MKCoordinateRegionWrapper.h
//  MapDistance
//
//  Created by Christian Dunn on 6/30/14.
//
//

#import <Foundation/Foundation.h>

@interface MKCoordinateRegionWrapper : NSObject

@property MKCoordinateRegion region;
@property (retain) NSString *string1;
@property (retain) NSString *string2;

-(NSString *) toString;
-(void) toLog;

@end
