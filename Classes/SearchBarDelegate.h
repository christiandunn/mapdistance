//
//  SearchBarDelegate.h
//  MapDistance
//
//  Created by Christian Dunn on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONKit.h"
#import "MKCoordinateRegionWrapper.h"


@interface SearchBarDelegate : NSObject <UISearchBarDelegate> {
    
    id<MapDistanceViewControllerProtocol> vc;
    NSDate *lastPetition;
    MKMapView *map_view;
}

@property (assign) id vc;
@property (assign) MKMapView *map_view;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;
- (void)foundGeocodedLocation:(MKCoordinateRegionWrapper *)_location;
- (void)didNotFindGeocodedLocation;
- (void)geocodeAddress:(NSString*) address;
- (NSDictionary*) parseJson:(NSString*) jsonString;

@end
