//
//  MapScaleView.h
//  MapDistance
//
//  Created by Christian Dunn on 8/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MapScaleView : MKAnnotationView {
    
    MKMapView *theMapView;
    NSNumberFormatter *nf;
}

@property (retain) MKMapView *theMapView;

- (void)initializeThis;

@end
