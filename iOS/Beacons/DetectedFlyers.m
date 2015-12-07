//
//  NearbyBeaconsSV.m
//  Beacons
//
//  Created by Martí Serra Vivancos on 10/05/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "DetectedFlyers.h"

@implementation DetectedFlyers

#define MARGIN 5
#define IMMEDIATE 1
#define NEAR 2
#define FAR 3

int attempts;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // View
        self.clipsToBounds = NO;
        self.pagingEnabled = YES;
        self.bounces = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        
        // NSMutableArrays
        _detectedBeacons = [[NSMutableArray alloc] init];
        _displayedBeacons = [[NSMutableArray alloc] init];
        _flyers = [[NSMutableArray alloc]init];
        _filteredFlyers = [[NSMutableArray alloc]init];
         _filterCategories = [[NSArray alloc]init];
        
        // Init beacons search tools
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;

        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"] identifier:@"com.Tomorrow.com"];
        _beaconRegion.notifyEntryStateOnDisplay = YES;
        _beaconRegion.notifyOnEntry = YES;
        _beaconRegion.notifyOnExit = YES;
        
        [self startRanging];
    }
    
    return self;
}

// Ranging core location
- (void) startRanging
{
    [_locationManager startRangingBeaconsInRegion:_beaconRegion];
}

- (void) stopRanging
{
    [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
}

// Detected beacons every frame
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // Reload realbeacons array with detected beacons
    [_detectedBeacons removeAllObjects];
    
    for (int i = 0; i<[beacons count]; i++)
    {
        CLBeacon *beacon = [[CLBeacon alloc] init];
        beacon = [beacons objectAtIndex:i];
        
        NSArray *info = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%li", (long)beacon.major.integerValue], [NSString stringWithFormat:@"%li", (long)beacon.minor.integerValue], nil];
        
        if (![_detectedBeacons containsObject:info])
        {
            [_detectedBeacons addObject:info];
        }
    }
    
    // Check for lost beacons
    for (int i = 0; i<[_displayedBeacons count]; i++)
    {
        // Detected beacons doesn't contain a displayed beacon -> users has lost it -> delete it from visual
        if (![_detectedBeacons containsObject:[_displayedBeacons objectAtIndex:i]])
        {
            NSLog(@"Deleting object at index %i", i);
            
            BeaconFlyer *flyer = (BeaconFlyer *)[_flyers objectAtIndex:i];
            
            // Analytics report
            NSDate *localDate = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            dateFormatter.dateFormat = @"MM/dd/yy HH:mm:ss";
            NSString *start = [dateFormatter stringFromDate: localDate];
            [flyer reportNewIntervalWithStartTime:start proximity:4 index:i];
            
            // Remove beacon and flyer
            [_displayedBeacons removeObjectAtIndex:i];
            [_flyers removeObjectAtIndex:i];
            [flyer removeBeaconFlyerWithAnalytics:YES];
            
            // Rearrange views
            if (flyer.fullscreen) [_detectedDelegate scrollHadBeaconExpanded:NO];
            
            [self rearrangeFlyers];
        }
    }
    
    // Check for new or disordered beacons
    for (int i = 0; i<[_detectedBeacons count]; i++)
    {
        // Displayed beacon has not the same object as detected in same index
        if ([_displayedBeacons containsObject:[_detectedBeacons objectAtIndex:i]])
        {
            // Problem: order
            if ([_displayedBeacons indexOfObject:[_detectedBeacons objectAtIndex:i]] != i)
            {
                NSLog(@"Reordering object at index %lu to index %i", (unsigned long)[_displayedBeacons indexOfObject:[_detectedBeacons objectAtIndex:i]],i);
                
                id flyer = [_flyers objectAtIndex:[_displayedBeacons indexOfObject:[_detectedBeacons objectAtIndex:i]]];
                [_flyers removeObjectAtIndex:[_displayedBeacons indexOfObject:[_detectedBeacons objectAtIndex:i]]];
                [_flyers insertObject:flyer atIndex:i];
                
                
                id info = [_displayedBeacons objectAtIndex:[_displayedBeacons indexOfObject:[_detectedBeacons objectAtIndex:i]]];
                [_displayedBeacons removeObjectAtIndex:[_displayedBeacons indexOfObject:[_detectedBeacons objectAtIndex:i]]];
                [_displayedBeacons insertObject:info atIndex:i];
                
                [self rearrangeFlyers];
            }
        }
        
        // Problem: new beacon
        else
        {
            NSLog(@"Adding flyer to index %i", i);
            
            // Add info to displayed array
            [_displayedBeacons insertObject:[_detectedBeacons objectAtIndex:i] atIndex:i];
            
            // Create flyer
            BeaconFlyer *flyer = [[BeaconFlyer alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width-MARGIN*2, self.frame.size.height-MARGIN*4)];
            flyer.flyerdelegate = self;
            flyer.alpha = 0;
            flyer.hidden = YES;
            
            // Add flyer to beacon array
            [_flyers insertObject:flyer atIndex:i];
            
            // Load content
            NSArray *info = [_detectedBeacons objectAtIndex:i];
            dispatch_sync( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                
                [flyer createBeaconFlyerWithCompanyId:(int)[[info objectAtIndex:0] integerValue] beaconId:(int)[[info objectAtIndex:1] integerValue] withCallback:^(BOOL completed){
                    
                    // Add flyer to view
                    [self addSubview:flyer];
                    
                    [self rearrangeFlyers];
                    
                }];
            });
            
        }
    }
    
    // Analytics detections
    for (int i = 0; i <[_detectedBeacons count]; i++) {
        
        BeaconFlyer *flyer = (BeaconFlyer*)[_flyers objectAtIndex:i];
        CLBeacon *beacon = [beacons objectAtIndex:i];
        
        NSDate *localDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MM-dd-yy HH:mm:ss";
        
        if (beacon.proximity == CLProximityImmediate && flyer.proximity != IMMEDIATE) {
            
            attempts++;
            
            if (attempts>1) {
                
                attempts = 0;
                
                NSString *start = [dateFormatter stringFromDate: localDate];
                flyer.proximity = IMMEDIATE;
                
                [flyer reportNewIntervalWithStartTime:start proximity:IMMEDIATE index:i];
            }
        }
        
        if (beacon.proximity == CLProximityNear && flyer.proximity != NEAR) {
            
            attempts++;
            
            if (attempts>1) {
                
                attempts = 0;
                
                NSString *start = [dateFormatter stringFromDate: localDate];
                flyer.proximity = NEAR;
                
                [flyer reportNewIntervalWithStartTime:start proximity:NEAR index:i];
            }
        }
        
        if (beacon.proximity == CLProximityFar && flyer.proximity != FAR) {
            
            attempts++;
            
            if (attempts>1) {
                
                attempts = 0;
                
                NSString *start = [dateFormatter stringFromDate: localDate];
                flyer.proximity = FAR;
                
                [flyer reportNewIntervalWithStartTime:start proximity:FAR index:i];
                
            }
        }
    }
}

// Flyer couldn't be loaded, delets
- (void) flyerDeletedUnexpect:(BeaconFlyer *)flyer
{
    [_displayedBeacons removeObjectAtIndex:[_flyers indexOfObject:flyer]];
    [_flyers removeObject:flyer];
}

// Rearrange flyers with new positions
- (void) rearrangeFlyers
{
    [_filteredFlyers removeAllObjects];
    
    NSLog(@"Displaying filtered flyers...");
    
    // Check if flyers have filtered categories -> hide them
    for (BeaconFlyer *flyer in _flyers)
    {
        if (![_filterCategories containsObject:flyer.category])
        {
            [_filteredFlyers addObject:flyer];
            
        } else flyer.hidden = YES;
    }
    
    self.contentSize = CGSizeMake(([_filteredFlyers count])*(self.frame.size.width), self.frame.size.height);
    
    for (BeaconFlyer *flyer in _filteredFlyers)
    {
        if ((flyer.alpha == 0) & flyer.hidden) flyer.frame = CGRectMake(MARGIN + [_filteredFlyers indexOfObject:flyer]*self.frame.size.width, flyer.frame.origin.y, flyer.frame.size.width, flyer.frame.size.height);
 
        [UIView animateWithDuration:0.25
                              delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             flyer.frame = CGRectMake(MARGIN + [_filteredFlyers indexOfObject:flyer]*self.frame.size.width, MARGIN, flyer.frame.size.width, flyer.frame.size.height);
                             flyer.alpha = 1;
                             flyer.hidden = NO;
                         } completion:nil];
    }
    
    // Reload pagecontrol
    [_detectedDelegate modifyPageControllNumber:[_filteredFlyers count]];
    [_detectedDelegate selectedPage:0];
    
}

// Adjust page controll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_detectedDelegate selectedPage:(round(scrollView.contentOffset.x / scrollView.bounds.size.width))];
}

// Reload favorite flyer's buttons
- (void) reloadFavButtons
{
    for (BeaconFlyer *btn in [self subviews])
    {
        if([btn isKindOfClass:[BeaconFlyer class]])
        {
            [btn reloadFavButton];
        }
    }
}

// Flyer delegate
- (void) beaconDidExpand:(BeaconFlyer *)flyer toState:(BOOL)fullscreen
{
    // Expand viwed flyer
    if (fullscreen)
    {
        //Enlarge scrollview
        [_detectedDelegate scrollHadBeaconExpanded:YES];
        
        // Enlarge flyer
        [UIView animateWithDuration:0.3
                              delay:0.0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             flyer.frame = CGRectMake(flyer.frame.origin.x-MARGIN, flyer.frame.origin.y-MARGIN, self.frame.size.width, self.frame.size.height);
                             
                         } completion:nil];
    }
    else
    {
        //Minimize scrollview
        [_detectedDelegate scrollHadBeaconExpanded:NO];
        
        [UIView animateWithDuration:0.3
         
                              delay:0.0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             flyer.frame = CGRectMake(flyer.frame.origin.x+MARGIN, MARGIN, self.frame.size.width-MARGIN*2, self.frame.size.height-MARGIN*4);
                             
                         } completion:nil];
    }
}

@end
