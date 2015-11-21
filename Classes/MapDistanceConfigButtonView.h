//
//  MapDistanceConfigButtonView.h
//  MapDistance
//
//  Created by Christian Dunn on 1/6/11.
//  Copyright 2011 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapDistanceAboutViewController.h"

#define CONFIG_SETTINGS_CONTENT_HEIGHT 410

@interface MapDistanceConfigButtonView : UIScrollView {

	NSUserDefaults *defaults;
	
	UILabel *title_label;
    UIButton *aboutButton;
    UIButton *close_button;
	
	UISegmentedControl *switch_units;
	UISegmentedControl *switch_offset;
    
    UILabel *automaticScrollSwitchLabel;
    UISwitch *automaticScrollSwitch;
    UILabel *pauseDrawingOnTouchUpLabel;
    UISwitch *pauseDrawingOnTouchUpSwitch;
    
    UILabel *latspanLabel;
    UILabel *latspanValueLabel;
    UISlider *latspanSlider;
    double latspan;
	
	UIViewController<MapDistanceViewControllerProtocol> *view_controller;
	
	NSString *language;
}

@property (assign) id view_controller;
@property (retain) NSString *language;
@property (assign) UISwitch *automaticScrollSwitch;

- (void)unitsFlipped;
- (void)offsetFlipped;
- (void)aboutButtonPressed;
- (void)closeButtonPressed;
- (void)useAutomaticScrollFlipped;
- (void)latspanSliderChanged;
- (void)pauseDrawSwitchFlipped;
@end
