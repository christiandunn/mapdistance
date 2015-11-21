//
//  SearchBarDelegate.m
//  MapDistance
//
//  Created by Christian Dunn on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchBarDelegate.h"

/*
 CLGeocoder         iOS 5.0 minimum
 MKLocalSearch      iOS 6.1 minimum
 https://developers.google.com/maps/ios-access
 */

@implementation SearchBarDelegate

@synthesize vc;
@synthesize map_view;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if(searchBar.text==nil || [searchBar.text isEqualToString:@""]) {
        return;
    }
    [searchBar resignFirstResponder];
    if ([[searchBar text] compare:@"debug"]==NSOrderedSame) {
        MKCoordinateRegionWrapper *w = [MKCoordinateRegionWrapper new];
        [w setString1:@"DEBUG_DEBUG_DEBUG"];
        [vc searchResultReturnedLocation:w];
        return;
    }
    [NSThread detachNewThreadSelector:@selector(geocodeAddress:) toTarget:self withObject:[searchBar text]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
}

-(void)foundGeocodedLocation:(MKCoordinateRegionWrapper *)_location {
    
    if(_location != nil && vc!=nil) {
        [vc searchResultReturnedLocation:_location];
    }
}

-(void)didNotFindGeocodedLocation {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"GeoCodeError", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil];
    [alertView show];
}

-(void)geocodeAddress:(NSString*) address {
        
    //NSLog(@"Geocoding address: %@", address);
    
    // don't make requests faster than 0.5 seconds
    // Google may block/ban your requests if you abuse the service
    double pause = 0.5;
    NSDate *now = [NSDate date];
    [now retain];
    NSTimeInterval elapsed = [now timeIntervalSinceDate:lastPetition];
    lastPetition = now;
    if (elapsed>0.0 && elapsed<pause){
        //NSLog(@"    Elapsed < pause = %f < %f, sleeping for %f seconds", elapsed, pause, pause-elapsed);
        [NSThread sleepForTimeInterval:pause-elapsed];
    }
    
    // url encode
    NSString *encodedAddress = (NSString *) CFURLCreateStringByAddingPercentEscapes(
                                                                                    NULL, (CFStringRef) address,
                                                                                    NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                                    kCFStringEncodingUTF8 );
    
    /* Bounds: Southwest and northeast corners */
    MKCoordinateRegion region = [map_view region];
    CLLocationCoordinate2D sw = CLLocationCoordinate2DMake(region.center.latitude - (region.span.latitudeDelta / 2.0), region.center.longitude - (region.span.longitudeDelta / 2.0));
    CLLocationCoordinate2D ne = CLLocationCoordinate2DMake(region.center.latitude + (region.span.latitudeDelta / 2.0), region.center.longitude + (region.span.longitudeDelta / 2.0));
    NSString *bounds_str = [NSString stringWithFormat:@"%f,%f|%f,%f", sw.latitude, sw.longitude, ne.latitude, ne.longitude];
    NSString *encoded_bounds_str = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)bounds_str, NULL, (CFStringRef)@"|", kCFStringEncodingUTF8);
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&bounds=%@&sensor=true", encodedAddress, encoded_bounds_str];
    [encodedAddress release];
    [encoded_bounds_str release];
    
    // try twice to geocode the address
    NSDictionary *dic;
    for (int i=0; i<2; i++) { // two tries
        //NSLog(@"Trying to geocode the address");
        NSURL *try_url = [NSURL URLWithString:url];
        NSString *page = [NSString stringWithContentsOfURL:try_url encoding:NSUTF8StringEncoding error:nil];
        //NSLog(@"%@", page);
        //NSLog([NSString stringWithFormat:@"PAGE: %@", page]);
        //NSLog(@"Try URL: %@", [url description]);
        dic = [self parseJson:page];
        NSString *status = (NSString*)[dic objectForKey:@"status"];
        BOOL success = [status isEqualToString:@"OK"];
        if (success) break;
        
        // Query failed
        // See http://code.google.com/apis/maps/documentation/geocoding/#StatusCodes
        if ([status isEqualToString:@"OVER_QUERY_LIMIT"]){
            //NSLog(@"try #%d", i);
            [NSThread sleepForTimeInterval:1];
        } else if ([status isEqualToString:@"ZERO_RESULTS"]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ZeroResults", @"") message:NSLocalizedString(@"ZeroResultsText", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"") otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            break;
        } else {
            // REQUEST_DENIED: no sensor parameter. Shouldn't happen.
            // INVALID_REQUEST: no address parameter or empty address. Doesn't matter.
        }
        
    }
    
    // if we fail after two tries, just leave
    NSString *status = (NSString*)[dic objectForKey:@"status"];
    BOOL success = [status isEqualToString:@"OK"];
    if (!success) {
        [self performSelectorOnMainThread:@selector(didNotFindGeocodedLocation) withObject:nil waitUntilDone:FALSE];
        return;
    }
    
    // extract the data
    {
        int results = (int)[[dic objectForKey:@"results"] count];
        if (results>1){
            //NSLog(@"    There are %d possible results for this address.", results);
        }
    }
    
    NSArray *resultsDic = [dic objectForKey:@"results"];
    NSDictionary *resultsDicFirstResult = [resultsDic objectAtIndex:0];
    
    NSDictionary *geometryDic = [resultsDicFirstResult objectForKey:@"geometry"];
    NSDictionary *northEastDic = [[geometryDic objectForKey:@"bounds"] objectForKey:@"northeast"];
    NSDictionary *southWestDic = [[geometryDic objectForKey:@"bounds"] objectForKey:@"southwest"];
    double lat1 = [[southWestDic objectForKey:@"lat"] doubleValue];
    double lon1 = [[southWestDic objectForKey:@"lng"] doubleValue];
    double lat2 = [[northEastDic objectForKey:@"lat"] doubleValue];
    double lon2 = [[northEastDic objectForKey:@"lng"] doubleValue];
    NSDictionary *locationDic = [[[[dic objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
    NSNumber *latitude = [locationDic objectForKey:@"lat"];
    NSNumber *longitude = [locationDic objectForKey:@"lng"];    
    
    NSArray *typesDic = [resultsDicFirstResult objectForKey:@"types"];
    NSString *firstType = [typesDic objectAtIndex:0];
    NSString *formattedAddress = [resultsDicFirstResult objectForKey:@"formatted_address"];
        
    MKCoordinateRegionWrapper *reg = [[MKCoordinateRegionWrapper alloc] init];
    MKCoordinateRegion mkregion = MKCoordinateRegionMake(CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]), MKCoordinateSpanMake(lat2 - lat1, lon2 - lon1 < 0 ? lon2 - lon1 + 360 : lon2 - lon1));
    [reg setRegion:mkregion];
    [reg setString1:formattedAddress];
    [reg setString2:[firstType stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
    [self performSelectorOnMainThread:@selector(foundGeocodedLocation:) withObject:reg waitUntilDone:FALSE];
}

- (NSDictionary*) parseJson:(NSString*) jsonString {
    
    NSDictionary *rootDict = nil;
    NSError *error = nil;
    @try {
        JKParseOptionFlags options = JKParseOptionComments | JKParseOptionUnicodeNewlines;
        rootDict = [jsonString objectFromJSONStringWithParseOptions:options error:&error];
        if (error) {
            //NSLog(@"%@",[error localizedDescription]);
        }
        //NSLog(@"    JSONKit: %lu characters resulted in %lu root node", (unsigned long)[jsonString length], (unsigned long)[rootDict count]);
        
    } @catch (NSException * e) {
        // If data is 0 bytes, here we get: "NSInvalidArgumentException The string argument is NULL"
        //NSLog(@"%@ %@", [e name], [e reason]);
        
        // abort
        rootDict = nil;
    }
    return rootDict;

}

@end
