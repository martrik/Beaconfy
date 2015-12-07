//
//  NearbyBeaconsSV.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 10/05/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BeaconFlyer.h"

@protocol DetectedFlyersDelegate;

@interface DetectedFlyers : UIScrollView <CLLocationManagerDelegate, BeaconFlyerDelegate, UIScrollViewDelegate>

// CLLocation
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

// Arrays
@property (strong, nonatomic) NSMutableArray *detectedBeacons;
@property (strong, nonatomic) NSMutableArray *displayedBeacons;
@property (strong, nonatomic) NSMutableArray *flyers;
@property (strong, nonatomic) NSMutableArray *filteredFlyers;

// functions
- (void) startRanging;
- (void) stopRanging;
- (void) reloadFavButtons;
- (void) rearrangeFlyers;

// Delegate
@property (assign, nonatomic) id<DetectedFlyersDelegate> detectedDelegate;

// Filter
@property (strong, nonatomic) NSArray *filterCategories;

@end

// Delegate protocol
@protocol DetectedFlyersDelegate <NSObject>

- (void) scrollHadBeaconExpanded: (BOOL) fullscreen;
- (void) modifyPageControllNumber: (NSInteger) pages;
- (void) selectedPage: (NSInteger) index;
- (void) didDetectBeacons: (BOOL) state;

@end