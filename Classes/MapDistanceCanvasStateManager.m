//
//  MapDistanceCanvasStateManager.m
//  MapDistance
//
//  Created by Christian Dunn on 12/19/15.
//
//

#import "MapDistanceCanvasStateManager.h"

@implementation MapDistanceCanvasStateManager

- (void)setCanvasStatus:(NSInteger)_CanvasStatus {
    
    CanvasStatus = _CanvasStatus;
}

- (NSInteger)getCanvasStatus {
    
    return CanvasStatus;
}

- (BOOL)canvasIsEditingPath {
    
    return CanvasStatus == 2;
}

@end
