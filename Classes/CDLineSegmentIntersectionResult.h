//
//  CDLineSegmentIntersectionResult.h
//  MapDistance
//
//  Created by Christian Dunn on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDLineSegmentIntersectionResult : NSObject {
    
    CGPoint intersection;
    BOOL intersects;
}

@property CGPoint intersection;
@property BOOL intersects;

@end
