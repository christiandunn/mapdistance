//
//  MapDistanceConfigButtonView.m
//  MapDistance
//
//  Created by Christian Dunn on 1/6/11.
//  Copyright 2011 Cornell University. All rights reserved.
//

#import "MapDistanceConfigButtonView.h"


@implementation MapDistanceConfigButtonView

@synthesize view_controller;
@synthesize language;
@synthesize automaticScrollSwitch;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.clipsToBounds= TRUE;
		self.backgroundColor= [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.9f];
        [self setContentSize:CGSizeMake(self.frame.size.width, CONFIG_SETTINGS_CONTENT_HEIGHT)];
		
		title_label= [UILabel alloc];
		title_label= [title_label initWithFrame:CGRectMake(10, 10, 150, 24)];
		[title_label setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f]];
		[title_label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
		[title_label setText:NSLocalizedString(@"Settings", @"...")];
		[self addSubview:title_label];
        
        if (language==nil) {
            aboutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [aboutButton setFrame:CGRectMake(180, 1, 120, 46)];
            [aboutButton setTitle:@"Help and About" forState:UIControlStateNormal];
            [aboutButton addTarget:self action:@selector(aboutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [aboutButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:16.0]];
            [aboutButton setTintColor:[UIColor blueColor]];
            [aboutButton setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.2f]];
            [self addSubview:aboutButton];
        }
		
		defaults= [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
		NSInteger metric = [defaults integerForKey:@"metric"];
        if (metric > 2 || metric < 0) {
            metric = 0;
        }
		NSInteger pixel_offset= 0;
		if ([defaults integerForKey:@"pixel_offset"]!=0) {
			pixel_offset= [defaults integerForKey:@"pixel_offset"];
		}
        BOOL useAutomaticScroll = [defaults boolForKey:@"UseAutomaticScroll"];
        BOOL pauseDrawOnTouchUp = [defaults boolForKey:@"PauseDrawOnTouchUp"];
        if (pixel_offset != 0) {
            pauseDrawOnTouchUp = TRUE;
            [pauseDrawingOnTouchUpSwitch setEnabled:FALSE];
        }
		
		UILabel *label_units= [UILabel alloc];
		label_units= [label_units initWithFrame:CGRectMake(10, 56, 200, 20)];
		label_units.backgroundColor= [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
		if (language==nil) {
			[label_units setText:@"Units of Measurement"];
		}
		else {
			if ([language compare:@"fr_FR"]==NSOrderedSame) {
				[label_units setText:@"Unités"];
			}
		}
		[self addSubview:label_units];
		
		switch_units= [UISegmentedControl alloc];
		switch_units= [switch_units initWithFrame:CGRectMake(10, 75, self.frame.size.width - 20, 50)];
		if (language==nil) {
			[switch_units insertSegmentWithTitle:@"U.S." atIndex:0 animated:FALSE];
			[switch_units insertSegmentWithTitle:@"Metric" atIndex:1 animated:FALSE];
            [switch_units insertSegmentWithImage:[UIImage imageNamed:@"129-golf.png"] atIndex:2 animated:FALSE];
		}
		else {
			if ([language compare:@"fr_FR"]==NSOrderedSame) {
                //Coutumier
				[switch_units insertSegmentWithTitle:@"É.-U.A." atIndex:0 animated:FALSE];
				[switch_units insertSegmentWithTitle:@"Métrique" atIndex:1 animated:FALSE];
                [switch_units insertSegmentWithImage:[UIImage imageNamed:@"129-golf.png"] atIndex:2 animated:FALSE];
			}
		}
		[switch_units setSelectedSegmentIndex:metric];
		[switch_units addTarget:self action:@selector(unitsFlipped) forControlEvents:UIControlEventValueChanged];
		[self addSubview:switch_units];
		
		UILabel *label_offset= [UILabel alloc];
		label_offset= [label_offset initWithFrame:CGRectMake(10, 137, self.frame.size.width - 20, 20)];
		label_offset.backgroundColor= [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
		[label_offset setText:NSLocalizedString(@"Label_Offset_Config", "Label_Offset_Config")];
		[self addSubview:label_offset];
		
		switch_offset= [UISegmentedControl alloc];
		switch_offset= [switch_offset initWithFrame:CGRectMake(10, 157, self.frame.size.width - 20, 50)];
		[switch_offset insertSegmentWithTitle:NSLocalizedString(@"Pixels_Low", "45 Pixels Low") atIndex:0 animated:FALSE];
		[switch_offset insertSegmentWithTitle:NSLocalizedString(@"Pixels_No_Offset", "No Offset") atIndex:1 animated:FALSE];
		[switch_offset insertSegmentWithTitle:NSLocalizedString(@"Pixels_Up", "45 Pixels Up") atIndex:2 animated:FALSE];
		[switch_offset setSelectedSegmentIndex:1];
		if (pixel_offset>0) {
			[switch_offset setSelectedSegmentIndex:0];
		}
		if (pixel_offset<0) {
			[switch_offset setSelectedSegmentIndex:2];
		}
		[switch_offset addTarget:self action:@selector(offsetFlipped) forControlEvents:UIControlEventValueChanged];
		[self addSubview:switch_offset];
        
        automaticScrollSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 225, 215, 20)];
        automaticScrollSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(245, 220, 100, 20)];
        [automaticScrollSwitchLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0f]];
        [automaticScrollSwitchLabel setTextAlignment:UITextAlignmentRight];
        [automaticScrollSwitchLabel setText:NSLocalizedString(@"UseAutomaticScroll", @"")];
        [automaticScrollSwitchLabel setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f]];
        [automaticScrollSwitch setOn:useAutomaticScroll animated:FALSE];
        [automaticScrollSwitch addTarget:self action:@selector(useAutomaticScrollFlipped) forControlEvents:UIControlEventValueChanged];
        [self addSubview:automaticScrollSwitchLabel];
        [self addSubview:automaticScrollSwitch];
        
        pauseDrawingOnTouchUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 264, 215, 20)];
        pauseDrawingOnTouchUpSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(245, 258, 100, 20)];
        [pauseDrawingOnTouchUpLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0f]];
        [pauseDrawingOnTouchUpLabel setTextAlignment:UITextAlignmentRight];
        [pauseDrawingOnTouchUpLabel setText:NSLocalizedString(@"PauseDrawingOnTouchUpLabel", @"")];
        [pauseDrawingOnTouchUpLabel setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f]];
        [pauseDrawingOnTouchUpSwitch setOn:pauseDrawOnTouchUp animated:FALSE];
        [pauseDrawingOnTouchUpSwitch addTarget:self action:@selector(pauseDrawSwitchFlipped) forControlEvents:UIControlEventValueChanged];
        [self addSubview:pauseDrawingOnTouchUpLabel];
        [self addSubview:pauseDrawingOnTouchUpSwitch];
        
        latspan = [defaults doubleForKey:@"latspan"];
        latspanLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 295, 285, 20)];
        [latspanLabel setText:NSLocalizedString(@"LatitudeSpanSettingLabel", @"")];
        [latspanLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
        [latspanLabel setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f]];
        latspanValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(255, 320, 70, 20)];
        [latspanValueLabel setText:@""];
        [latspanValueLabel setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f]];
        [latspanValueLabel setText:[NSString stringWithFormat:@"%2.2f°", latspan]];
        latspanSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, 320, 235, 20)];
        [latspanSlider addTarget:self action:@selector(latspanSliderChanged) forControlEvents:UIControlEventValueChanged];
        [latspanSlider setValue:latspan*(1/20.0)];
        [self addSubview:latspanLabel];
        [self addSubview:latspanValueLabel];
        [self addSubview:latspanSlider];
		
		close_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [close_button setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.2f]];
        [[close_button titleLabel] setFont:[UIFont fontWithName:@"Helvetica Bold" size:24.0f]];
		[close_button setFrame:CGRectMake(10, 350, self.frame.size.width - 20, 50)];
		if (language==nil) {
			[close_button setTitle:@"Close" forState:UIControlStateNormal];
		}
		else {
			if ([language compare:@"fr_FR"]==NSOrderedSame) {
				[close_button setTitle:@"Fermer" forState:UIControlStateNormal];
			}
		}
		[close_button addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:close_button];
    }
    return self;
}

- (void)unitsFlipped {
	
	NSInteger metric= switch_units.selectedSegmentIndex;
	[defaults setInteger:metric forKey:@"metric"];
    [defaults synchronize];
    [view_controller refreshUnits];
}

- (void)offsetFlipped {
	
	if ([switch_offset selectedSegmentIndex]==0) {
		[defaults setInteger:80 forKey:@"pixel_offset"];
	}
	if ([switch_offset selectedSegmentIndex]==1) {
		[defaults setInteger:0 forKey:@"pixel_offset"];
	}
	if ([switch_offset selectedSegmentIndex]==2) {
		[defaults setInteger:-80 forKey:@"pixel_offset"];
	}
	[defaults synchronize];
    
    if ([switch_offset selectedSegmentIndex] != 1) {
        [pauseDrawingOnTouchUpSwitch setOn:TRUE animated:TRUE];
        [self pauseDrawSwitchFlipped];
        [pauseDrawingOnTouchUpSwitch setEnabled:FALSE];
    } else {
        [pauseDrawingOnTouchUpSwitch setEnabled:TRUE];
    }
}

- (void)aboutButtonPressed {
    
    MapDistanceAboutViewController *avc = [[MapDistanceAboutViewController alloc] initWithNibName:@"MapDistanceAboutViewController" bundle:nil];
    [view_controller presentModalViewController:avc animated:TRUE];
    [view_controller infoButtonViewCloseButtonPressed];
}

- (void)closeButtonPressed {
	
	[view_controller infoButtonViewCloseButtonPressed];
}

- (void)useAutomaticScrollFlipped {
    
    if (automaticScrollSwitch.on) {
        [defaults setBool:TRUE forKey:@"UseAutomaticScroll"];
    } else {
        [defaults setBool:FALSE forKey:@"UseAutomaticScroll"];
    }
    [defaults synchronize];
}

- (void)latspanSliderChanged {
    
    latspan = latspanSlider.value * 20.0;
    [latspanValueLabel setText:[NSString stringWithFormat:@"%2.2f°", latspan]];
    [defaults setDouble:latspan forKey:@"latspan"];
    [defaults synchronize];
}

- (void)pauseDrawSwitchFlipped {
    
    [defaults setBool:pauseDrawingOnTouchUpSwitch.on forKey:@"PauseDrawOnTouchUp"];
    [defaults synchronize];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.frame.size.height > CONFIG_SETTINGS_CONTENT_HEIGHT) {
        [self setScrollEnabled:FALSE];
    }
    [self setContentSize:CGSizeMake(self.frame.size.width, CONFIG_SETTINGS_CONTENT_HEIGHT)];
    [switch_units setFrame:CGRectMake(switch_units.frame.origin.x, switch_units.frame.origin.y, self.frame.size.width - 20, switch_units.frame.size.height)];
    [switch_offset setFrame:CGRectMake(switch_offset.frame.origin.x, switch_offset.frame.origin.y, self.frame.size.width - 20, switch_offset.frame.size.height)];
    [close_button setFrame:CGRectMake(close_button.frame.origin.x, close_button.frame.origin.y, self.frame.size.width - 20, close_button.frame.size.height)];
    
}

- (void)dealloc {
    [super dealloc];
}


@end
