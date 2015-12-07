//
//  FavBeaconsScroll.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 08/06/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconFlyer.h"
#import "FilterVC.h"

@protocol FavoritedFlyersDelegate;

@interface FavoritedFlyers : UIScrollView <BeaconFlyerDelegate, UIScrollViewDelegate>

// Reload Beacons
- (void) reloadFavFlyers;
- (void) rearrangeFlyers;

// Displayed flyer array
@property (strong, nonatomic) NSMutableArray *favoritedBeacons;
@property (strong, nonatomic) NSMutableArray *favoritedFlyers;
@property (strong, nonatomic) NSMutableArray *filteredFavoritedFlyers;
@property (strong, nonatomic) NSArray *filterCategories;

// Delegate
@property (assign, nonatomic) id<FavoritedFlyersDelegate> favdelegate;

@end

// Delegate protocol
@protocol FavoritedFlyersDelegate <NSObject>

- (void) scrollHadBeaconExpanded: (BOOL) fullscreen;
- (void) modifyPageControllNumber: (NSInteger) pages;
- (void) selectedPage: (NSInteger) index;

@end