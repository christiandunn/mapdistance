//
//  AppReviewQuestion.h
//  MapDistance
//
//  Created by Christian Dunn on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppReviewQuestion : NSObject <UIAlertViewDelegate> {
    
    NSUserDefaults *user_defaults;
    UIAlertView *considerReviewingAppAlertView;
}

- (id)initWithConfig:(NSUserDefaults *)_defaults;
- (void)main;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
