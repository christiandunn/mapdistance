//
//  LabelWithAction.m
//  MapDistance
//
//  Created by Christian Dunn on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LabelWithAction.h"

@implementation LabelWithAction

@synthesize labelTapInvocation;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //Disable super call because we want the label to INTERCEPT touch events
    //The super call would pass the touch event through the label
    //[super touchesBegan:touches withEvent:event];
    [labelTapInvocation invoke];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    ;
}

- (void)setDeleteTimerWithSeconds:(NSTimeInterval)seconds {
    [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(removeFromSuperview) userInfo:nil repeats:FALSE];
}

@end
