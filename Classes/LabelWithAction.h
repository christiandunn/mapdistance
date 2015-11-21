//
//  LabelWithAction.h
//  MapDistance
//
//  Created by Christian Dunn on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LabelWithAction : UILabel {
    
    NSInvocation *labelTapInvocation;
}

@property (retain) NSInvocation *labelTapInvocation;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)setDeleteTimerWithSeconds:(NSTimeInterval)seconds;

@end
