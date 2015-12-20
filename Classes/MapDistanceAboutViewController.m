//
//  MapDistanceAboutViewController.m
//  MapDistance
//
//  Created by Christian Dunn on 1/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapDistanceAboutViewController.h"

@implementation MapDistanceAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [documentationCloseButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [documentationCloseButton setTitle:NSLocalizedString(@"Close", @"") forState:UIControlStateNormal];
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pathOnMapDistanceDocumentation.pdf"];;
    NSData *documentation = [NSData dataWithContentsOfFile:filePath];
    [documentationWebView loadData:documentation MIMEType:@"application/pdf" textEncodingName:@"UTF8String" baseURL:[[NSBundle mainBundle] resourceURL]];
    
    NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [versionLabel setText:[NSString stringWithFormat:@"%@", versionString]];
}

- (void)closeButtonPressed {
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
