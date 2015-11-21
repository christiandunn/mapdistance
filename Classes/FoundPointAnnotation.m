//
//  FoundPointAnnotation.m
//  MapDistance
//
//  Created by Christian Dunn on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FoundPointAnnotation.h"

@implementation FoundPointAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (void)setTitle:(NSString *)_title {
    
    title = _title;
}

- (void)setSubtitle:(NSString *)_subtitle {
    
    subtitle = _subtitle;
}

@end
