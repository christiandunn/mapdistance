//
//  MapDistanceCanvasStateManager.h
//  MapDistance
//
//  Created by Christian Dunn on 12/19/15.
//
//

#import <Foundation/Foundation.h>

@interface MapDistanceCanvasStateManager : NSObject {
    
    NSInteger CanvasStatus;
}

- (NSInteger)getCanvasStatus;
- (void)setCanvasStatus:(NSInteger)_CanvasStatus;

- (BOOL)canvasIsEditingPath;

@end
